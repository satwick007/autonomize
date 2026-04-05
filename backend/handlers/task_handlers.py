from __future__ import annotations

from fastapi import APIRouter, Depends, File, UploadFile
from fastapi.responses import FileResponse, StreamingResponse
from sqlalchemy.orm import Session
import csv
import io
from typing import Optional

from businesslogic.task_logic import (
    bulk_create_tasks,
    create_comment,
    create_task,
    ensure_comment_owner,
    get_analytics,
    get_attachment_or_404,
    get_comment_or_404,
    get_comments,
    get_dashboard_overview,
    get_task_metadata,
    get_task_or_404,
    list_board_tasks,
    list_tasks,
    save_attachment,
    serialize_task,
    soft_delete_attachment,
    soft_delete_comment,
    soft_delete_task,
    update_comment,
    update_task,
)
from common.database import get_db
from common.dependencies import get_current_user
from common.schemas import (
    AnalyticsResponse,
    AttachmentResponse,
    BulkTaskCreateRequest,
    CommentCreateRequest,
    CommentResponse,
    CommentUpdateRequest,
    DashboardOverviewResponse,
    TaskMetadataResponse,
    PaginatedTasksResponse,
    TaskCreateRequest,
    TaskResponse,
    TaskUpdateRequest,
)


router = APIRouter(tags=["Tasks"])


@router.get("/metadata", response_model=TaskMetadataResponse)
def task_metadata_endpoint(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return get_task_metadata(db)


@router.post("/tasks", response_model=TaskResponse, status_code=201)
def create_task_endpoint(
    payload: TaskCreateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    task = create_task(payload, current_user.id, db)
    return serialize_task(task)


@router.post("/tasks/bulk", response_model=list[TaskResponse], status_code=201)
def bulk_create_tasks_endpoint(
    payload: BulkTaskCreateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    tasks = bulk_create_tasks(payload, current_user.id, db)
    return [serialize_task(task) for task in tasks]


@router.get("/tasks", response_model=PaginatedTasksResponse)
def list_tasks_endpoint(
    search: Optional[str] = None,
    state: Optional[str] = None,
    priority: Optional[str] = None,
    tag: Optional[str] = None,
    assigned_to_id: Optional[str] = None,
    sort_by: str = "created_at",
    sort_order: str = "desc",
    page: int = 1,
    page_size: int = 10,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return list_tasks(db, search, state, priority, tag, assigned_to_id, sort_by, sort_order, page, page_size)


@router.get("/tasks/board", response_model=list[TaskResponse])
def list_board_tasks_endpoint(
    search: Optional[str] = None,
    state: Optional[str] = None,
    priority: Optional[str] = None,
    tag: Optional[str] = None,
    assigned_to_id: Optional[str] = None,
    sort_by: str = "created_at",
    sort_order: str = "desc",
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return list_board_tasks(db, search, state, priority, tag, assigned_to_id, sort_by, sort_order)


@router.get("/tasks/{task_id}", response_model=TaskResponse)
def get_task_endpoint(task_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    task = get_task_or_404(task_id, db)
    return serialize_task(task)


@router.put("/tasks/{task_id}", response_model=TaskResponse)
def update_task_endpoint(
    task_id: int,
    payload: TaskUpdateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    task = get_task_or_404(task_id, db)
    task = update_task(task, payload, db)
    return serialize_task(task)


@router.delete("/tasks/{task_id}", status_code=204)
def delete_task_endpoint(task_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    task = get_task_or_404(task_id, db)
    soft_delete_task(task, db)


@router.post("/tasks/{task_id}/comments", response_model=CommentResponse, status_code=201)
def add_comment_endpoint(
    task_id: int,
    payload: CommentCreateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    task = get_task_or_404(task_id, db)
    comment = create_comment(task, current_user.id, payload.content, db)
    return {
        "id": comment.id,
        "task_id": comment.task_id,
        "author_id": comment.author_id,
        "author_name": comment.author.full_name,
        "content": comment.content,
        "created_at": comment.created_at,
        "updated_at": comment.updated_at,
    }


@router.get("/tasks/{task_id}/comments", response_model=list[CommentResponse])
def get_task_comments_endpoint(
    task_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    get_task_or_404(task_id, db)
    comments = get_comments(task_id, db)
    return [
        {
            "id": comment.id,
            "task_id": comment.task_id,
            "author_id": comment.author_id,
            "author_name": comment.author.full_name,
            "content": comment.content,
            "created_at": comment.created_at,
            "updated_at": comment.updated_at,
        }
        for comment in comments
    ]


@router.put("/comments/{comment_id}", response_model=CommentResponse)
def update_comment_endpoint(
    comment_id: int,
    payload: CommentUpdateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    comment = get_comment_or_404(comment_id, db)
    ensure_comment_owner(comment, current_user.id)
    comment = update_comment(comment, payload.content, db)
    return {
        "id": comment.id,
        "task_id": comment.task_id,
        "author_id": comment.author_id,
        "author_name": comment.author.full_name,
        "content": comment.content,
        "created_at": comment.created_at,
        "updated_at": comment.updated_at,
    }


@router.delete("/comments/{comment_id}", status_code=204)
def delete_comment_endpoint(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    comment = get_comment_or_404(comment_id, db)
    ensure_comment_owner(comment, current_user.id)
    soft_delete_comment(comment, db)


@router.post("/tasks/{task_id}/attachments", response_model=AttachmentResponse, status_code=201)
def upload_attachment_endpoint(
    task_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    task = get_task_or_404(task_id, db)
    attachment = save_attachment(task, current_user.id, file, db)
    return {
        "id": attachment.id,
        "task_id": attachment.task_id,
        "file_name": attachment.file_name,
        "file_path": attachment.file_path,
        "file_size_bytes": attachment.file_size_bytes,
        "content_type": attachment.content_type,
        "uploaded_by_id": attachment.uploaded_by_id,
        "uploaded_at": attachment.uploaded_at,
    }


@router.get("/attachments/{attachment_id}/download")
def download_attachment_endpoint(
    attachment_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    attachment = get_attachment_or_404(attachment_id, db)
    return FileResponse(attachment.file_path, filename=attachment.file_name, media_type=attachment.content_type)


@router.delete("/attachments/{attachment_id}", status_code=204)
def delete_attachment_endpoint(
    attachment_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    attachment = get_attachment_or_404(attachment_id, db)
    soft_delete_attachment(attachment, db)


@router.get("/analytics/overview", response_model=AnalyticsResponse)
def analytics_overview_endpoint(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return get_analytics(db)


@router.get("/dashboard/overview", response_model=DashboardOverviewResponse)
def dashboard_overview_endpoint(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return get_dashboard_overview(db, current_user.id)


@router.get("/analytics/export")
def export_tasks_endpoint(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    result = list_tasks(
        db=db,
        search=None,
        state=None,
        priority=None,
        tag=None,
        assigned_to_id=None,
        sort_by="created_at",
        sort_order="desc",
        page=1,
        page_size=1000,
    )
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(["ID", "Title", "Assigned To", "State", "Priority", "Target Date", "Created At"])
    for item in result["items"]:
        writer.writerow(
            [
                item["id"],
                item["title"],
                item["assigned_to_name"] or "",
                item["state"],
                item["priority"],
                item["target_date"] or "",
                item["created_at"],
            ]
        )
    memory = io.BytesIO(buffer.getvalue().encode("utf-8"))
    headers = {"Content-Disposition": "attachment; filename=tasks-export.csv"}
    return StreamingResponse(memory, media_type="text/csv", headers=headers)
