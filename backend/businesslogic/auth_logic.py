from datetime import datetime, timedelta, timezone
from random import randint

from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from common.mailer import send_registration_otp_email
from common.security import build_token_expiration, create_access_token, generate_session_id, hash_password, verify_password
from common.schemas import (
    RegistrationOtpRequest,
    RegistrationOtpVerifyRequest,
    UserLoginRequest,
    UserPasswordChangeRequest,
    UserProfileUpdateRequest,
    UserRegisterRequest,
)
from config.settings import get_settings
from datamodels.entities import RegistrationOtp, User, UserSession


settings = get_settings()


def _create_session(user_id: int, db: Session):
    session_id = generate_session_id()
    expires_at = build_token_expiration()
    session = UserSession(user_id=user_id, session_token_id=session_id, expires_at=expires_at)
    db.add(session)
    db.flush()
    token = create_access_token(str(user_id), session_id=session_id)
    return token, session


def register_user(payload: UserRegisterRequest, db: Session):
    existing_user = db.query(User).filter(User.email == payload.email.lower()).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    user = User(
        full_name=payload.full_name.strip(),
        email=payload.email.lower(),
        password_hash=hash_password(payload.password),
    )
    db.add(user)
    db.flush()
    token, _ = _create_session(user.id, db)
    db.commit()
    db.refresh(user)
    return {"access_token": token, "user": user}


def request_registration_otp(payload: RegistrationOtpRequest, db: Session):
    existing_user = db.query(User).filter(User.email == payload.email.lower()).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    active_otps = (
        db.query(RegistrationOtp)
        .filter(
            RegistrationOtp.email == payload.email.lower(),
            RegistrationOtp.is_used.is_(False),
        )
        .all()
    )
    for otp_entry in active_otps:
        otp_entry.is_used = True
        otp_entry.updated_at = datetime.utcnow()
        db.add(otp_entry)

    otp_code = f"{randint(0, 999999):06d}"
    otp_entry = RegistrationOtp(
        full_name=payload.full_name.strip(),
        email=payload.email.lower(),
        password_hash=hash_password(payload.password),
        otp_code=otp_code,
        expires_at=datetime.utcnow() + timedelta(minutes=settings.registration_otp_expire_minutes),
    )
    db.add(otp_entry)
    db.commit()

    send_registration_otp_email(otp_entry.email, otp_entry.full_name, otp_code)
    return {
        "message": "OTP sent successfully",
        "delivery_method": "email",
    }


def verify_registration_otp(payload: RegistrationOtpVerifyRequest, db: Session):
    existing_user = db.query(User).filter(User.email == payload.email.lower()).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    otp_entry = (
        db.query(RegistrationOtp)
        .filter(
            RegistrationOtp.email == payload.email.lower(),
            RegistrationOtp.is_used.is_(False),
        )
        .order_by(RegistrationOtp.created_at.desc())
        .first()
    )
    if not otp_entry or otp_entry.expires_at < datetime.utcnow():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="OTP has expired. Please request a new one.")
    if otp_entry.otp_code != payload.otp.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid OTP")

    user = User(
        full_name=otp_entry.full_name,
        email=otp_entry.email,
        password_hash=otp_entry.password_hash,
    )
    db.add(user)
    db.flush()

    otp_entry.is_used = True
    otp_entry.updated_at = datetime.utcnow()
    db.add(otp_entry)

    token, _ = _create_session(user.id, db)
    db.commit()
    db.refresh(user)
    return {"access_token": token, "user": user}


def login_user(payload: UserLoginRequest, db: Session):
    user = db.query(User).filter(User.email == payload.email.lower(), User.is_active.is_(True)).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")

    token, _ = _create_session(user.id, db)
    db.commit()
    return {"access_token": token, "user": user}


def update_profile(user: User, payload: UserProfileUpdateRequest, db: Session):
    user.full_name = payload.full_name.strip()
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def change_password(user: User, payload: UserPasswordChangeRequest, db: Session):
    if not verify_password(payload.current_password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Current password is incorrect")
    if payload.current_password == payload.new_password:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="New password must be different from the current password")

    user.password_hash = hash_password(payload.new_password)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def revoke_session(user: User, session_id: str, db: Session) -> None:
    session = (
        db.query(UserSession)
        .filter(
            UserSession.user_id == user.id,
            UserSession.session_token_id == session_id,
            UserSession.is_active.is_(True),
        )
        .first()
    )
    if not session:
        return

    session.is_active = False
    session.updated_at = datetime.now(timezone.utc).replace(tzinfo=None)
    db.add(session)
    db.commit()
