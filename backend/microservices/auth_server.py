from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from common.database import init_database
from common.error_handlers import register_exception_handlers
from config.settings import get_settings
from handlers.auth_handlers import router as auth_router


settings = get_settings()

app = FastAPI(title="Task Platform Auth Service", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(auth_router, prefix="/api")
register_exception_handlers(app)


@app.on_event("startup")
def on_startup():
    init_database()


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "auth"}

