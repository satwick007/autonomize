from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time

from common.database import init_database
from common.error_handlers import register_exception_handlers
from config.settings import get_settings
from handlers.task_handlers import router as task_router


settings = get_settings()
app = FastAPI(title="Task Platform Task Service", version="1.0.0")

request_log: dict[str, list[float]] = {}


@app.middleware("http")
async def simple_rate_limit(request: Request, call_next):
    client_host = request.client.host if request.client else "anonymous"
    now = time.time()
    timestamps = [stamp for stamp in request_log.get(client_host, []) if now - stamp < 60]
    if len(timestamps) >= settings.rate_limit_per_minute:
        return JSONResponse(status_code=429, content={"detail": "Rate limit exceeded"})
    timestamps.append(now)
    request_log[client_host] = timestamps
    return await call_next(request)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(task_router, prefix="/api")
register_exception_handlers(app)


@app.on_event("startup")
def on_startup():
    init_database()


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "tasks"}
