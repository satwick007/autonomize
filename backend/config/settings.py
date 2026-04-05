from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Optional
from pydantic import BaseSettings, Field


BASE_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    app_name: str = Field("Task Management Platform", env="APP_NAME")
    auth_service_port: int = Field(3000, env="AUTH_SERVICE_PORT")
    task_service_port: int = Field(3001, env="TASK_SERVICE_PORT")
    debug: bool = Field(True, env="DEBUG")

    postgres_user: str = Field("postgres", env="POSTGRES_USER")
    postgres_password: str = Field("satwick", env="POSTGRES_PASSWORD")
    postgres_host: str = Field("localhost", env="POSTGRES_HOST")
    postgres_port: int = Field(5432, env="POSTGRES_PORT")
    postgres_db: str = Field("task_management_satwick", env="POSTGRES_DB")
    database_url: Optional[str] = Field(None, env="DATABASE_URL")

    jwt_secret_key: str = Field("change-me-in-env", env="JWT_SECRET_KEY")
    jwt_algorithm: str = Field("HS256", env="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(60 * 8, env="ACCESS_TOKEN_EXPIRE_MINUTES")
    registration_otp_expire_minutes: int = Field(10, env="REGISTRATION_OTP_EXPIRE_MINUTES")
    smtp_host: Optional[str] = Field(None, env="SMTP_HOST")
    smtp_port: int = Field(587, env="SMTP_PORT")
    smtp_username: Optional[str] = Field(None, env="SMTP_USERNAME")
    smtp_password: Optional[str] = Field(None, env="SMTP_PASSWORD")
    smtp_from_email: Optional[str] = Field(None, env="SMTP_FROM_EMAIL")
    smtp_use_tls: bool = Field(True, env="SMTP_USE_TLS")

    cors_origins: str = Field("http://localhost:4200,http://127.0.0.1:4200", env="CORS_ORIGINS")
    upload_dir: str = Field(str(BASE_DIR / "uploads"), env="UPLOAD_DIR")
    max_upload_size_mb: int = Field(10, env="MAX_UPLOAD_SIZE_MB")
    allowed_file_extensions: str = Field("png,jpg,jpeg,pdf,doc,docx,txt", env="ALLOWED_FILE_EXTENSIONS")
    rate_limit_per_minute: int = Field(120, env="RATE_LIMIT_PER_MINUTE")

    class Config:
        env_file = str(BASE_DIR / "backend" / ".env")
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
