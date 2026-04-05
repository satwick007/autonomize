from __future__ import annotations

from datetime import datetime, timedelta, timezone
from uuid import uuid4
from passlib.context import CryptContext
import jwt

from config.settings import get_settings


pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
settings = get_settings()


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    return pwd_context.verify(password, hashed_password)


def build_token_expiration(expires_delta: timedelta | None = None) -> datetime:
    return datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.access_token_expire_minutes)
    )


def create_access_token(subject: str, session_id: str, expires_delta: timedelta | None = None) -> str:
    expire = build_token_expiration(expires_delta)
    payload = {"sub": subject, "sid": session_id, "exp": expire}
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> dict:
    return jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])


def generate_session_id() -> str:
    return uuid4().hex
