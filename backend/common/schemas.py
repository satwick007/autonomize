from __future__ import annotations

from datetime import datetime, date
from typing import Dict, List, Optional

from pydantic import BaseModel, EmailStr, Field, validator


class UserRegisterRequest(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=128)


class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=128)


class UserProfileUpdateRequest(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=120)


class UserPasswordChangeRequest(BaseModel):
    current_password: str = Field(..., min_length=6, max_length=128)
    new_password: str = Field(..., min_length=6, max_length=128)


class UserResponse(BaseModel):
    id: int
    full_name: str
    email: EmailStr
    created_at: datetime

    class Config:
        orm_mode = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class TaskCreateRequest(BaseModel):
    title: str = Field(..., min_length=3, max_length=160)
    description: str = Field("", max_length=5000)
    state: str = "todo"
    priority: str = "medium"
    assigned_to_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    target_date: Optional[date] = None
    tags: List[str] = Field(default_factory=list)

    @validator("tags", pre=True)
    def normalize_tags(cls, value):
        if value is None:
            return []
        return [str(item).strip() for item in value if str(item).strip()]


class TaskUpdateRequest(BaseModel):
    title: Optional[str] = Field(default=None, min_length=3, max_length=160)
    description: Optional[str] = Field(default=None, max_length=5000)
    state: Optional[str] = None
    priority: Optional[str] = None
    assigned_to_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    target_date: Optional[date] = None
    tags: Optional[List[str]] = None


class BulkTaskCreateRequest(BaseModel):
    tasks: List[TaskCreateRequest] = Field(..., min_items=1, max_items=100)


class CommentCreateRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class CommentUpdateRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class CommentResponse(BaseModel):
    id: int
    task_id: int
    author_id: int
    author_name: str
    content: str
    created_at: datetime
    updated_at: datetime


class AttachmentResponse(BaseModel):
    id: int
    task_id: int
    file_name: str
    file_path: str
    file_size_bytes: int
    content_type: Optional[str]
    uploaded_by_id: int
    uploaded_at: datetime


class TaskResponse(BaseModel):
    id: int
    title: str
    description: str
    state_id: int
    state: str
    priority_id: int
    priority: str
    assigned_to_id: Optional[int]
    assigned_to_name: Optional[str]
    start_date: Optional[date]
    end_date: Optional[date]
    target_date: Optional[date]
    tag_ids: List[int]
    tags: List[str]
    created_at: datetime
    updated_at: datetime
    attachments: List[AttachmentResponse] = Field(default_factory=list)
    comments_count: int = 0


class PaginatedTasksResponse(BaseModel):
    total: int
    page: int
    page_size: int
    items: List[TaskResponse]


class AnalyticsResponse(BaseModel):
    by_state: Dict[str, int]
    by_priority: Dict[str, int]
    completed_over_time: List[dict]
    user_performance: List[dict]


class DashboardMiniStatResponse(BaseModel):
    label: str
    value: int


class DashboardDueSoonTaskResponse(BaseModel):
    id: int
    title: str
    assigned_to_name: Optional[str]
    state: str
    target_date: Optional[date]


class DashboardTeamPulseResponse(BaseModel):
    name: str
    count: int
    review: int


class DashboardRecentTaskResponse(BaseModel):
    id: int
    title: str
    assigned_to_name: Optional[str]
    priority: str
    state: str
    updated_at: datetime


class DashboardTimelinePointResponse(BaseModel):
    date: str
    label: str
    count: int


class DashboardOverviewResponse(BaseModel):
    total: int
    overdue: int
    unassigned: int
    my_work: List[DashboardMiniStatResponse]
    state_cards: List[DashboardMiniStatResponse]
    priority_cards: List[DashboardMiniStatResponse]
    due_timeline: List[DashboardTimelinePointResponse]
    due_soon: List[DashboardDueSoonTaskResponse]
    team_pulse: List[DashboardTeamPulseResponse]
    recently_touched: List[DashboardRecentTaskResponse]


class MasterOptionResponse(BaseModel):
    id: int
    code: str
    label: str


class TagOptionResponse(BaseModel):
    id: int
    name: str


class TaskMetadataResponse(BaseModel):
    states: List[MasterOptionResponse]
    priorities: List[MasterOptionResponse]
    tags: List[TagOptionResponse]
