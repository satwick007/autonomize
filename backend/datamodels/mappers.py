from sqlalchemy.orm import relationship, registry

from datamodels.entities import Attachment, Comment, RegistrationOtp, TagMaster, Task, TaskPriorityMaster, TaskStateMaster, User, UserSession
from datamodels.tables import (
    attachments_table,
    comments_table,
    registration_otps_table,
    tags_master_table,
    task_tags_table,
    task_priorities_table,
    task_states_table,
    tasks_table,
    user_sessions_table,
    users_table,
)


mapper_registry = registry()
_is_mapped = False


def map_models() -> None:
    global _is_mapped
    if _is_mapped:
        return

    mapper_registry.map_imperatively(
        User,
        users_table,
        properties={
            "created_tasks": relationship(
                Task,
                primaryjoin=users_table.c.id == tasks_table.c.creator_id,
                back_populates="creator",
            ),
            "assigned_tasks": relationship(
                Task,
                primaryjoin=users_table.c.id == tasks_table.c.assigned_to_id,
                back_populates="assignee",
            ),
            "comments": relationship(Comment, back_populates="author"),
            "sessions": relationship(UserSession, back_populates="user"),
        },
    )

    mapper_registry.map_imperatively(
        UserSession,
        user_sessions_table,
        properties={
            "user": relationship(User, back_populates="sessions"),
        },
    )

    mapper_registry.map_imperatively(RegistrationOtp, registration_otps_table)

    mapper_registry.map_imperatively(
        TaskStateMaster,
        task_states_table,
        properties={
            "tasks": relationship(Task, back_populates="state_option"),
        },
    )

    mapper_registry.map_imperatively(
        TaskPriorityMaster,
        task_priorities_table,
        properties={
            "tasks": relationship(Task, back_populates="priority_option"),
        },
    )

    mapper_registry.map_imperatively(
        TagMaster,
        tags_master_table,
        properties={
            "tasks": relationship(Task, secondary=task_tags_table, back_populates="tags"),
        },
    )

    mapper_registry.map_imperatively(
        Task,
        tasks_table,
        properties={
            "creator": relationship(
                User,
                primaryjoin=tasks_table.c.creator_id == users_table.c.id,
                back_populates="created_tasks",
            ),
            "assignee": relationship(
                User,
                primaryjoin=tasks_table.c.assigned_to_id == users_table.c.id,
                back_populates="assigned_tasks",
            ),
            "state_option": relationship(TaskStateMaster, back_populates="tasks"),
            "priority_option": relationship(TaskPriorityMaster, back_populates="tasks"),
            "tags": relationship(TagMaster, secondary=task_tags_table, back_populates="tasks"),
            "comments": relationship(Comment, back_populates="task"),
            "attachments": relationship(Attachment, back_populates="task"),
        },
    )

    mapper_registry.map_imperatively(
        Comment,
        comments_table,
        properties={
            "task": relationship(Task, back_populates="comments"),
            "author": relationship(User, back_populates="comments"),
        },
    )

    mapper_registry.map_imperatively(
        Attachment,
        attachments_table,
        properties={
            "task": relationship(Task, back_populates="attachments"),
            "uploaded_by": relationship(User),
        },
    )

    _is_mapped = True
