from __future__ import annotations

from datetime import date, datetime


class User:
    def __init__(self, full_name: str, email: str, password_hash: str):
        self.full_name = full_name
        self.email = email
        self.password_hash = password_hash
        self.is_active = True
        self.created_at = datetime.utcnow()


class UserSession:
    def __init__(self, user_id: int, session_token_id: str, expires_at: datetime):
        self.user_id = user_id
        self.session_token_id = session_token_id
        self.expires_at = expires_at
        self.is_active = True
        self.created_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()


class Task:
    def __init__(
        self,
        title: str,
        description: str,
        state: str,
        priority: str,
        creator_id: int,
        assigned_to_id: int | None = None,
        start_date: date | None = None,
        end_date: date | None = None,
        target_date: date | None = None,
        tags: str = "",
    ):
        self.title = title
        self.description = description
        self.state = state
        self.priority = priority
        self.creator_id = creator_id
        self.assigned_to_id = assigned_to_id
        self.start_date = start_date
        self.end_date = end_date
        self.target_date = target_date
        self.tags = tags
        self.is_deleted = False
        self.created_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()


class Comment:
    def __init__(self, task_id: int, author_id: int, content: str):
        self.task_id = task_id
        self.author_id = author_id
        self.content = content
        self.created_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()
        self.is_deleted = False


class Attachment:
    def __init__(
        self,
        task_id: int,
        uploaded_by_id: int,
        file_name: str,
        file_path: str,
        file_size_bytes: int,
        content_type: str | None,
    ):
        self.task_id = task_id
        self.uploaded_by_id = uploaded_by_id
        self.file_name = file_name
        self.file_path = file_path
        self.file_size_bytes = file_size_bytes
        self.content_type = content_type
        self.uploaded_at = datetime.utcnow()
        self.is_deleted = False


class TaskStateMaster:
    def __init__(self, code: str, label: str, sort_order: int):
        self.code = code
        self.label = label
        self.sort_order = sort_order
        self.is_active = True


class TaskPriorityMaster:
    def __init__(self, code: str, label: str, sort_order: int):
        self.code = code
        self.label = label
        self.sort_order = sort_order
        self.is_active = True


class TagMaster:
    def __init__(self, name: str):
        self.name = name
        self.is_active = True
