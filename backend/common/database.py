from sqlalchemy import create_engine
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
