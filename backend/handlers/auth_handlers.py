from fastapi import APIRouter, Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from businesslogic.auth_logic import (
    change_password,
    login_user,
    register_user,
    request_registration_otp,
    revoke_session,
    update_profile,
    verify_registration_otp,
)
from common.database import get_db
from common.dependencies import get_current_user
from common.security import decode_access_token
from common.schemas import (
    RegistrationOtpRequest,
    RegistrationOtpResponse,
    RegistrationOtpVerifyRequest,
    TokenResponse,
    UserLoginRequest,
    UserPasswordChangeRequest,
    UserProfileUpdateRequest,
    UserRegisterRequest,
    UserResponse,
)
from datamodels.entities import User


router = APIRouter(prefix="/auth", tags=["Authentication"])
bearer_scheme = HTTPBearer(auto_error=True)


@router.post("/register", response_model=TokenResponse, status_code=201)
def register(payload: UserRegisterRequest, db: Session = Depends(get_db)):
    result = register_user(payload, db)
    return {"access_token": result["access_token"], "user": result["user"]}


@router.post("/register/request-otp", response_model=RegistrationOtpResponse)
def request_register_otp_endpoint(payload: RegistrationOtpRequest, db: Session = Depends(get_db)):
    return request_registration_otp(payload, db)


@router.post("/register/verify-otp", response_model=TokenResponse, status_code=201)
def verify_register_otp_endpoint(payload: RegistrationOtpVerifyRequest, db: Session = Depends(get_db)):
    result = verify_registration_otp(payload, db)
    return {"access_token": result["access_token"], "user": result["user"]}


@router.post("/login", response_model=TokenResponse)
def login(payload: UserLoginRequest, db: Session = Depends(get_db)):
    result = login_user(payload, db)
    return {"access_token": result["access_token"], "user": result["user"]}


@router.get("/me", response_model=UserResponse)
def get_profile(current_user=Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=UserResponse)
def update_profile_endpoint(
    payload: UserProfileUpdateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return update_profile(current_user, payload, db)


@router.put("/change-password", status_code=204)
def change_password_endpoint(
    payload: UserPasswordChangeRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    change_password(current_user, payload, db)


@router.post("/logout", status_code=204)
def logout_endpoint(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    payload = decode_access_token(credentials.credentials)
    session_id = payload.get("sid")
    if session_id:
        revoke_session(current_user, session_id, db)


@router.get("/users", response_model=list[UserResponse])
def list_users(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return db.query(User).filter(User.is_active.is_(True)).order_by(User.full_name.asc()).all()
