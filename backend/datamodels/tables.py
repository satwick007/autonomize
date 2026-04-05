from sqlalchemy import (
    Boolean,
    Column,
    Date,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    MetaData,
    String,
    Table,
    Text,
)


metadata = MetaData()


users_table = Table(
    "users",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("full_name", String(120), nullable=False),
    Column("email", String(255), nullable=False, unique=True, index=True),
    Column("password_hash", String(255), nullable=False),
    Column("is_active", Boolean, nullable=False, default=True),
    Column("created_at", DateTime, nullable=False),
)

user_sessions_table = Table(
    "user_sessions",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("user_id", Integer, ForeignKey("users.id"), nullable=False, index=True),
    Column("session_token_id", String(64), nullable=False, unique=True, index=True),
    Column("expires_at", DateTime, nullable=False, index=True),
    Column("is_active", Boolean, nullable=False, default=True, index=True),
    Column("created_at", DateTime, nullable=False),
    Column("updated_at", DateTime, nullable=False),
)

registration_otps_table = Table(
    "registration_otps",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("full_name", String(120), nullable=False),
    Column("email", String(255), nullable=False, index=True),
    Column("password_hash", String(255), nullable=False),
    Column("otp_code", String(6), nullable=False, index=True),
    Column("expires_at", DateTime, nullable=False, index=True),
    Column("is_used", Boolean, nullable=False, default=False, index=True),
    Column("created_at", DateTime, nullable=False),
    Column("updated_at", DateTime, nullable=False),
)

task_states_table = Table(
    "task_states_master",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("code", String(32), nullable=False, unique=True, index=True),
    Column("label", String(80), nullable=False),
    Column("sort_order", Integer, nullable=False, default=0),
    Column("is_active", Boolean, nullable=False, default=True, index=True),
)

task_priorities_table = Table(
    "task_priorities_master",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("code", String(32), nullable=False, unique=True, index=True),
    Column("label", String(80), nullable=False),
    Column("sort_order", Integer, nullable=False, default=0),
    Column("is_active", Boolean, nullable=False, default=True, index=True),
)

tags_master_table = Table(
    "tags_master",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("name", String(80), nullable=False, unique=True, index=True),
    Column("is_active", Boolean, nullable=False, default=True, index=True),
)

tasks_table = Table(
    "tasks",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("title", String(160), nullable=False, index=True),
    Column("description", Text, nullable=False, default=""),
    Column("state_id", Integer, ForeignKey("task_states_master.id"), nullable=False, index=True),
    Column("priority_id", Integer, ForeignKey("task_priorities_master.id"), nullable=False, index=True),
    Column("creator_id", Integer, ForeignKey("users.id"), nullable=False, index=True),
    Column("assigned_to_id", Integer, ForeignKey("users.id"), nullable=True, index=True),
    Column("start_date", Date, nullable=True),
    Column("end_date", Date, nullable=True),
    Column("target_date", Date, nullable=True, index=True),
    Column("is_deleted", Boolean, nullable=False, default=False, index=True),
    Column("created_at", DateTime, nullable=False, index=True),
    Column("updated_at", DateTime, nullable=False),
)

task_tags_table = Table(
    "task_tags",
    metadata,
    Column("task_id", Integer, ForeignKey("tasks.id"), primary_key=True),
    Column("tag_id", Integer, ForeignKey("tags_master.id"), primary_key=True),
)

comments_table = Table(
    "comments",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("task_id", Integer, ForeignKey("tasks.id"), nullable=False, index=True),
    Column("author_id", Integer, ForeignKey("users.id"), nullable=False),
    Column("content", Text, nullable=False),
    Column("created_at", DateTime, nullable=False),
    Column("updated_at", DateTime, nullable=False),
    Column("is_deleted", Boolean, nullable=False, default=False, index=True),
)

attachments_table = Table(
    "attachments",
    metadata,
    Column("id", Integer, primary_key=True),
    Column("task_id", Integer, ForeignKey("tasks.id"), nullable=False, index=True),
    Column("uploaded_by_id", Integer, ForeignKey("users.id"), nullable=False),
    Column("file_name", String(255), nullable=False),
    Column("file_path", String(500), nullable=False),
    Column("file_size_bytes", Integer, nullable=False),
    Column("content_type", String(120), nullable=True),
    Column("uploaded_at", DateTime, nullable=False),
    Column("is_deleted", Boolean, nullable=False, default=False, index=True),
)

Index("ix_tasks_state_priority", tasks_table.c.state_id, tasks_table.c.priority_id)
Index("ix_task_tags_tag_id", task_tags_table.c.tag_id)
Index("ix_comments_task_active", comments_table.c.task_id, comments_table.c.is_deleted)
Index("ix_attachments_task_active", attachments_table.c.task_id, attachments_table.c.is_deleted)
