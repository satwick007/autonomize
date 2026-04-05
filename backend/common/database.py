from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import scoped_session, sessionmaker

from config.settings import get_settings
from datamodels.entities import TagMaster, TaskPriorityMaster, TaskStateMaster
from datamodels.mappers import map_models
from datamodels.tables import metadata


settings = get_settings()

engine = create_engine(settings.sqlalchemy_database_url, future=False, pool_pre_ping=True)
SessionLocal = scoped_session(
    sessionmaker(bind=engine, autoflush=False, autocommit=False, expire_on_commit=False)
)


def init_database() -> None:
    map_models()
    metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_master_data(db)
    finally:
        db.close()
    migrate_legacy_task_schema()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def seed_master_data(db) -> None:
    default_states = [
        ("todo", "Todo", 1),
        ("in_progress", "In Progress", 2),
        ("review", "Review", 3),
        ("done", "Done", 4),
    ]
    default_priorities = [
        ("low", "Low", 1),
        ("medium", "Medium", 2),
        ("high", "High", 3),
        ("critical", "Critical", 4),
    ]
    default_tags = ["backend", "frontend", "bug", "urgent", "design", "api"]

    changed = False
    for code, label, sort_order in default_states:
        existing = db.query(TaskStateMaster).filter(TaskStateMaster.code == code).first()
        if not existing:
            db.add(TaskStateMaster(code=code, label=label, sort_order=sort_order))
            changed = True
    for code, label, sort_order in default_priorities:
        existing = db.query(TaskPriorityMaster).filter(TaskPriorityMaster.code == code).first()
        if not existing:
            db.add(TaskPriorityMaster(code=code, label=label, sort_order=sort_order))
            changed = True
    for name in default_tags:
        existing = db.query(TagMaster).filter(TagMaster.name == name).first()
        if not existing:
            db.add(TagMaster(name=name))
            changed = True
    if changed:
        db.commit()


def migrate_legacy_task_schema() -> None:
    inspector = inspect(engine)
    task_columns = {column["name"] for column in inspector.get_columns("tasks")}
    has_legacy_state = "state" in task_columns
    has_legacy_priority = "priority" in task_columns
    has_legacy_tags = "tags" in task_columns

    with engine.begin() as connection:
        connection.execute(text("""
            ALTER TABLE tasks
            ADD COLUMN IF NOT EXISTS state_id INTEGER REFERENCES task_states_master(id)
        """))
        connection.execute(text("""
            ALTER TABLE tasks
            ADD COLUMN IF NOT EXISTS priority_id INTEGER REFERENCES task_priorities_master(id)
        """))

        connection.execute(text("""
            CREATE INDEX IF NOT EXISTS ix_tasks_state_id ON tasks (state_id)
        """))
        connection.execute(text("""
            CREATE INDEX IF NOT EXISTS ix_tasks_priority_id ON tasks (priority_id)
        """))
        connection.execute(text("""
            CREATE INDEX IF NOT EXISTS ix_tasks_state_priority ON tasks (state_id, priority_id)
        """))
        connection.execute(text("""
            CREATE INDEX IF NOT EXISTS ix_task_tags_tag_id ON task_tags (tag_id)
        """))

        if has_legacy_state:
            connection.execute(text("""
                UPDATE tasks
                SET state_id = task_states_master.id
                FROM task_states_master
                WHERE tasks.state_id IS NULL
                  AND lower(coalesce(tasks.state, '')) = task_states_master.code
            """))
        if has_legacy_priority:
            connection.execute(text("""
                UPDATE tasks
                SET priority_id = task_priorities_master.id
                FROM task_priorities_master
                WHERE tasks.priority_id IS NULL
                  AND lower(coalesce(tasks.priority, '')) = task_priorities_master.code
            """))
        connection.execute(text("""
            UPDATE tasks
            SET state_id = (SELECT id FROM task_states_master WHERE code = 'todo')
            WHERE state_id IS NULL
        """))
        connection.execute(text("""
            UPDATE tasks
            SET priority_id = (SELECT id FROM task_priorities_master WHERE code = 'medium')
            WHERE priority_id IS NULL
        """))

        if has_legacy_tags:
            connection.execute(text("""
                INSERT INTO tags_master (name, is_active)
                SELECT DISTINCT lower(trim(tag_value)), TRUE
                FROM tasks,
                     regexp_split_to_table(coalesce(tasks.tags, ''), ',') AS tag_value
                WHERE trim(tag_value) <> ''
                  AND NOT EXISTS (
                      SELECT 1
                      FROM tags_master
                      WHERE tags_master.name = lower(trim(tag_value))
                  )
            """))
            connection.execute(text("""
                INSERT INTO task_tags (task_id, tag_id)
                SELECT DISTINCT tasks.id, tags_master.id
                FROM tasks
                JOIN regexp_split_to_table(coalesce(tasks.tags, ''), ',') AS tag_value ON TRUE
                JOIN tags_master ON tags_master.name = lower(trim(tag_value))
                WHERE trim(tag_value) <> ''
                ON CONFLICT DO NOTHING
            """))

        connection.execute(text("""
            ALTER TABLE tasks
            ALTER COLUMN state_id SET NOT NULL
        """))
        connection.execute(text("""
            ALTER TABLE tasks
            ALTER COLUMN priority_id SET NOT NULL
        """))

        if has_legacy_state:
            connection.execute(text("ALTER TABLE tasks DROP COLUMN IF EXISTS state"))
        if has_legacy_priority:
            connection.execute(text("ALTER TABLE tasks DROP COLUMN IF EXISTS priority"))
        if has_legacy_tags:
            connection.execute(text("ALTER TABLE tasks DROP COLUMN IF EXISTS tags"))
