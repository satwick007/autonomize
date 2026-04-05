from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Optional
from pydantic import BaseSettings, Field


BASE_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    app_name: str = "Task Management Platform"
    auth_service_port: int = 3000
    task_service_port: int = 3001
    debug: bool = True

    postgres_user: str = "postgres"
    postgres_password: str = "satwick"
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    postgres_db: str = "task_management_satwick"
    database_url: Optional[str] = None

    jwt_secret_key: str = Field("change-me-in-env", env="JWT_SECRET_KEY")
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 8

    cors_origins: str = "http://localhost:4200,http://127.0.0.1:4200"
    upload_dir: str = str(BASE_DIR / "uploads")
    max_upload_size_mb: int = 10
    allowed_file_extensions: str = "png,jpg,jpeg,pdf,doc,docx,txt"
    rate_limit_per_minute: int = 120

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False

    @property
    def sqlalchemy_database_url(self) -> str:
        if self.database_url:
            return self.database_url
        return (
            f"postgresql+psycopg2://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @property
    def allowed_extensions(self) -> set[str]:
        return {extension.strip().lower() for extension in self.allowed_file_extensions.split(",") if extension.strip()}


@lru_cache
def get_settings() -> Settings:
    settings = Settings()
    Path(settings.upload_dir).mkdir(parents=True, exist_ok=True)
    return settings
