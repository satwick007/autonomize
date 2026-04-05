from __future__ import annotations

from datetime import datetime, timedelta
from pathlib import Path
from uuid import uuid4

from fastapi import HTTPException, UploadFile, status
from sqlalchemy import func, or_
from sqlalchemy.orm import Session, selectinload

from common.schemas import BulkTaskCreateRequest, TaskCreateRequest, TaskUpdateRequest
from config.settings import get_settings
from datamodels.entities import Attachment, Comment, TagMaster, Task, TaskPriorityMaster, TaskStateMaster, User


settings = get_settings()


def _parse_csv_values(value: str | None) -> list[str]:
    if not value:
        return []
    return [item.strip() for item in value.split(",") if item.strip()]


def serialize_task(task: Task) -> dict:
    active_attachments = [attachment for attachment in task.attachments if not attachment.is_deleted]
    active_comments = [comment for comment in task.comments if not comment.is_deleted]
    return {
        "id": task.id,
        "title": task.title,
        "description": task.description,
        "state": task.state,
        "priority": task.priority,
        "assigned_to_id": task.assigned_to_id,
        "assigned_to_name": task.assignee.full_name if task.assignee else None,
        "start_date": task.start_date,
        "end_date": task.end_date,
        "target_date": task.target_date,
        "tags": [item for item in (task.tags or "").split(",") if item],
        "created_at": task.created_at,
        "updated_at": task.updated_at,
        "attachments": [
            {
                "id": attachment.id,
                "task_id": attachment.task_id,
                "file_name": attachment.file_name,
                "file_path": attachment.file_path,
                "file_size_bytes": attachment.file_size_bytes,
                "content_type": attachment.content_type,
                "uploaded_by_id": attachment.uploaded_by_id,
                "uploaded_at": attachment.uploaded_at,
            }
            for attachment in active_attachments
        ],
        "comments_count": len(active_comments),
    }


def _validate_assignee(assigned_to_id: int | None, db: Session) -> None:
    if assigned_to_id is None:
        return
    user = db.query(User).filter(User.id == assigned_to_id, User.is_active.is_(True)).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Assigned user not found")


def _validate_state(state: str, db: Session) -> str:
    normalized = state.strip().lower()
    option = db.query(TaskStateMaster).filter(TaskStateMaster.code == normalized, TaskStateMaster.is_active.is_(True)).first()
    if not option:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Unsupported task state: {state}")
    return option.code


def _validate_priority(priority: str, db: Session) -> str:
    normalized = priority.strip().lower()
    option = db.query(TaskPriorityMaster).filter(TaskPriorityMaster.code == normalized, TaskPriorityMaster.is_active.is_(True)).first()
    if not option:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Unsupported task priority: {priority}")
    return option.code


def _normalize_tags(tags: list[str], db: Session) -> list[str]:
    normalized_tags: list[str] = []
    for raw_tag in tags:
        tag = raw_tag.strip().lower()
        if not tag:
            continue
        existing = db.query(TagMaster).filter(TagMaster.name == tag).first()
        if not existing:
            db.add(TagMaster(name=tag))
            db.flush()
        normalized_tags.append(tag)
    return normalized_tags


def create_task(payload: TaskCreateRequest, creator_id: int, db: Session) -> Task:
    _validate_assignee(payload.assigned_to_id, db)
    state = _validate_state(payload.state, db)
    priority = _validate_priority(payload.priority, db)
    tags = _normalize_tags(payload.tags, db)
    task = Task(
        title=payload.title.strip(),
        description=payload.description.strip(),
        state=state,
        priority=priority,
        creator_id=creator_id,
        assigned_to_id=payload.assigned_to_id,
        start_date=payload.start_date,
        end_date=payload.end_date,
        target_date=payload.target_date,
        tags=",".join(tags),
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


def bulk_create_tasks(payload: BulkTaskCreateRequest, creator_id: int, db: Session) -> list[Task]:
    tasks = [create_task(task_payload, creator_id, db) for task_payload in payload.tasks]
    return tasks


def get_task_or_404(task_id: int, db: Session) -> Task:
    task = (
        db.query(Task)
        .options(
            selectinload(Task.assignee),
            selectinload(Task.attachments),
            selectinload(Task.comments),
        )
        .filter(Task.id == task_id, Task.is_deleted.is_(False))
        .first()
    )
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    return task


def update_task(task: Task, payload: TaskUpdateRequest, db: Session) -> Task:
    data = payload.dict(exclude_unset=True)
    if "assigned_to_id" in data:
        _validate_assignee(data["assigned_to_id"], db)
    if "state" in data and data["state"] is not None:
        data["state"] = _validate_state(data["state"], db)
    if "priority" in data and data["priority"] is not None:
        data["priority"] = _validate_priority(data["priority"], db)
    if "tags" in data and data["tags"] is not None:
        data["tags"] = ",".join(_normalize_tags(data["tags"], db))
    for key, value in data.items():
        setattr(task, key, value)
    task.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(task)
    return task


def soft_delete_task(task: Task, db: Session) -> None:
    task.is_deleted = True
    task.updated_at = datetime.utcnow()
    db.commit()


def list_tasks(
    db: Session,
    search: str | None,
    state: str | None,
    priority: str | None,
    tag: str | None,
    assigned_to_id: int | None,
    sort_by: str,
    sort_order: str,
    page: int,
    page_size: int,
):
    query = db.query(Task).filter(Task.is_deleted.is_(False))

    if search:
        pattern = f"%{search.strip()}%"
        query = query.filter(or_(Task.title.ilike(pattern), Task.description.ilike(pattern)))
    states = _parse_csv_values(state)
    if states:
        query = query.filter(Task.state.in_(states))
    priorities = _parse_csv_values(priority)
    if priorities:
        query = query.filter(Task.priority.in_(priorities))
    tags = [item.lower() for item in _parse_csv_values(tag)]
    if tags:
        query = query.filter(or_(*[Task.tags.ilike(f"%{item}%") for item in tags]))
    assigned_ids = [int(item) for item in _parse_csv_values(str(assigned_to_id) if assigned_to_id is not None else None) if item.isdigit()]
    if assigned_ids:
        query = query.filter(Task.assigned_to_id.in_(assigned_ids))

    allowed_sort_fields = {
        "id": Task.id,
        "created_at": Task.created_at,
        "updated_at": Task.updated_at,
        "assigned_to_id": Task.assigned_to_id,
        "priority": Task.priority,
        "start_date": Task.start_date,
        "end_date": Task.end_date,
        "target_date": Task.target_date,
        "title": Task.title,
        "state": Task.state,
    }
    sort_column = allowed_sort_fields.get(sort_by, Task.created_at)
    ordered_query = query.order_by(sort_column.desc() if sort_order == "desc" else sort_column.asc())
    loaded_query = ordered_query.options(
        selectinload(Task.assignee),
        selectinload(Task.attachments),
        selectinload(Task.comments),
    )

    total = query.count()
    items = loaded_query.offset((page - 1) * page_size).limit(page_size).all()
    return {"total": total, "page": page, "page_size": page_size, "items": [serialize_task(task) for task in items]}


def create_comment(task: Task, author_id: int, content: str, db: Session) -> Comment:
    comment = Comment(task_id=task.id, author_id=author_id, content=content.strip())
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return comment


def get_comments(task_id: int, db: Session) -> list[Comment]:
    return (
        db.query(Comment)
        .filter(Comment.task_id == task_id, Comment.is_deleted.is_(False))
        .order_by(Comment.created_at.asc())
        .all()
    )


def get_comment_or_404(comment_id: int, db: Session) -> Comment:
    comment = db.query(Comment).filter(Comment.id == comment_id, Comment.is_deleted.is_(False)).first()
    if not comment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Comment not found")
    return comment


def ensure_comment_owner(comment: Comment, user_id: int) -> None:
    if comment.author_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only edit or delete your own comments",
        )


def update_comment(comment: Comment, content: str, db: Session) -> Comment:
    comment.content = content.strip()
    comment.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(comment)
    return comment


def soft_delete_comment(comment: Comment, db: Session) -> None:
    comment.is_deleted = True
    comment.updated_at = datetime.utcnow()
    db.commit()


def validate_upload(file: UploadFile) -> None:
    extension = Path(file.filename or "").suffix.replace(".", "").lower()
    if not extension or extension not in settings.allowed_extensions:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unsupported file type")


def save_attachment(task: Task, uploaded_by_id: int, file: UploadFile, db: Session) -> Attachment:
    validate_upload(file)
    unique_name = f"{uuid4().hex}_{file.filename}"
    destination = Path(settings.upload_dir) / unique_name
    contents = file.file.read()
    max_size = settings.max_upload_size_mb * 1024 * 1024
    if len(contents) > max_size:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="File exceeds size limit")

    destination.write_bytes(contents)
    attachment = Attachment(
        task_id=task.id,
        uploaded_by_id=uploaded_by_id,
        file_name=file.filename or unique_name,
        file_path=str(destination),
        file_size_bytes=len(contents),
        content_type=file.content_type,
    )
    db.add(attachment)
    db.commit()
    db.refresh(attachment)
    return attachment


def get_attachment_or_404(attachment_id: int, db: Session) -> Attachment:
    attachment = db.query(Attachment).filter(Attachment.id == attachment_id, Attachment.is_deleted.is_(False)).first()
    if not attachment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Attachment not found")
    return attachment


def soft_delete_attachment(attachment: Attachment, db: Session) -> None:
    attachment.is_deleted = True
    db.commit()


def get_analytics(db: Session) -> dict:
    by_state_rows = (
        db.query(Task.state, func.count(Task.id))
        .filter(Task.is_deleted.is_(False))
        .group_by(Task.state)
        .all()
    )
    by_priority_rows = (
        db.query(Task.priority, func.count(Task.id))
        .filter(Task.is_deleted.is_(False))
        .group_by(Task.priority)
        .all()
    )
    completed_rows = (
        db.query(Task.end_date, func.count(Task.id))
        .filter(Task.is_deleted.is_(False), Task.state == "done", Task.end_date.isnot(None))
        .group_by(Task.end_date)
        .order_by(Task.end_date.asc())
        .all()
    )
    performance_rows = (
        db.query(User.full_name, func.count(Task.id))
        .join(Task, Task.assigned_to_id == User.id)
        .filter(Task.is_deleted.is_(False), Task.state == "done")
        .group_by(User.full_name)
        .order_by(func.count(Task.id).desc())
        .all()
    )

    return {
        "by_state": {state: count for state, count in by_state_rows},
        "by_priority": {priority: count for priority, count in by_priority_rows},
        "completed_over_time": [{"date": completed_date.isoformat(), "count": count} for completed_date, count in completed_rows],
        "user_performance": [{"user": full_name, "completed_tasks": count} for full_name, count in performance_rows],
    }


def get_dashboard_overview(db: Session, current_user_id: int) -> dict:
    tasks = (
        db.query(Task)
        .options(selectinload(Task.assignee))
        .filter(Task.is_deleted.is_(False))
        .all()
    )

    today = datetime.utcnow().date()
    next_week = today + timedelta(days=7)

    my_tasks = [task for task in tasks if task.assigned_to_id == current_user_id]
    open_tasks = [task for task in tasks if task.state != "done"]
    unassigned_tasks = [task for task in open_tasks if not task.assigned_to_id]
    review_tasks = [task for task in tasks if task.state == "review"]

    due_soon_candidates = [
        task for task in open_tasks
        if task.target_date is not None and today <= task.target_date <= next_week
    ]
    due_soon = sorted(due_soon_candidates, key=lambda task: (task.target_date or today, task.id))[:5]
    overdue = len([task for task in open_tasks if task.target_date is not None and task.target_date < today])

    my_work = [
        {"label": "Assigned to me", "value": len(my_tasks)},
        {"label": "In progress", "value": len([task for task in my_tasks if task.state == "in_progress"])},
        {"label": "Needs review", "value": len([task for task in my_tasks if task.state == "review"])},
        {"label": "Due this week", "value": len([task for task in due_soon_candidates if task.assigned_to_id == current_user_id])},
    ]

    state_cards = [
        {"label": "To Do", "value": len([task for task in tasks if task.state == "todo"])},
        {"label": "In Progress", "value": len([task for task in tasks if task.state == "in_progress"])},
        {"label": "Review", "value": len(review_tasks)},
        {"label": "Done", "value": len([task for task in tasks if task.state == "done"])},
    ]

    priority_cards = [
        {"label": "Critical", "value": len([task for task in tasks if task.priority == "critical"])},
        {"label": "High", "value": len([task for task in tasks if task.priority == "high"])},
        {"label": "Medium", "value": len([task for task in tasks if task.priority == "medium"])},
        {"label": "Low", "value": len([task for task in tasks if task.priority == "low"])},
    ]

    due_timeline = []
    for day_offset in range(7):
        current_date = today + timedelta(days=day_offset)
        due_timeline.append(
            {
                "date": current_date.isoformat(),
                "label": current_date.strftime("%-d %b"),
                "count": len([task for task in open_tasks if task.target_date == current_date]),
            }
        )

    team_pulse_map: dict[str, dict[str, int | str]] = {}
    for task in open_tasks:
        name = task.assignee.full_name if task.assignee else "Unassigned"
        if name not in team_pulse_map:
            team_pulse_map[name] = {"name": name, "count": 0, "review": 0}
        team_pulse_map[name]["count"] += 1
        if task.state == "review":
            team_pulse_map[name]["review"] += 1
    team_pulse = sorted(team_pulse_map.values(), key=lambda item: int(item["count"]), reverse=True)[:5]

    recently_touched = sorted(tasks, key=lambda task: task.updated_at, reverse=True)[:5]

    return {
        "total": len(tasks),
        "overdue": overdue,
        "unassigned": len(unassigned_tasks),
        "my_work": my_work,
        "state_cards": state_cards,
        "priority_cards": priority_cards,
        "due_timeline": due_timeline,
        "due_soon": [
            {
                "id": task.id,
                "title": task.title,
                "assigned_to_name": task.assignee.full_name if task.assignee else None,
                "state": task.state,
                "target_date": task.target_date,
            }
            for task in due_soon
        ],
        "team_pulse": team_pulse,
        "recently_touched": [
            {
                "id": task.id,
                "title": task.title,
                "assigned_to_name": task.assignee.full_name if task.assignee else None,
                "priority": task.priority,
                "state": task.state,
                "updated_at": task.updated_at,
            }
            for task in recently_touched
        ],
    }


def get_task_metadata(db: Session) -> dict:
    states = (
        db.query(TaskStateMaster)
        .filter(TaskStateMaster.is_active.is_(True))
        .order_by(TaskStateMaster.sort_order.asc(), TaskStateMaster.label.asc())
        .all()
    )
    priorities = (
        db.query(TaskPriorityMaster)
        .filter(TaskPriorityMaster.is_active.is_(True))
        .order_by(TaskPriorityMaster.sort_order.asc(), TaskPriorityMaster.label.asc())
        .all()
    )
    tags = (
        db.query(TagMaster)
        .filter(TagMaster.is_active.is_(True))
        .order_by(TagMaster.name.asc())
        .all()
    )
    return {
        "states": [{"id": item.id, "code": item.code, "label": item.label} for item in states],
        "priorities": [{"id": item.id, "code": item.code, "label": item.label} for item in priorities],
        "tags": [{"id": item.id, "name": item.name} for item in tags],
    }
