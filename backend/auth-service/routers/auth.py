from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from datetime import datetime
from database import get_db
from models.user import User
from schemas.user import UserCreate, UserLogin, TokenResponse, UserResponse
from services.auth_service import (
    generate_salt, hash_password, verify_password,
    create_access_token, create_refresh_token, decode_token
)

router = APIRouter(prefix="/auth", tags=["认证"])

@router.post("/register", response_model=TokenResponse)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(
        (User.phone == user_data.phone) | (User.id_card == user_data.id_card)
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already exists")

    salt = generate_salt()
    user = User(
        phone=user_data.phone,
        id_card=user_data.id_card,
        password_hash=hash_password(user_data.password, salt),
        salt=salt,
        user_type=user_data.user_type
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token_data = {"sub": str(user.id), "phone": user.phone}
    return TokenResponse(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data)
    )

@router.post("/login", response_model=TokenResponse)
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    query = db.query(User)
    if login_data.login_type == "phone":
        user = query.filter(User.phone == login_data.identifier).first()
    else:
        user = query.filter(User.id_card == login_data.identifier).first()

    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    if not verify_password(login_data.password, user.salt, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    user.last_login_ip = "127.0.0.1"
    db.commit()

    token_data = {"sub": str(user.id), "phone": user.phone}
    return TokenResponse(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data)
    )

@router.post("/refresh", response_model=TokenResponse)
def refresh_token(refresh_token: str, db: Session = Depends(get_db)):
    payload = decode_token(refresh_token)
    if payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid token type")

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    token_data = {"sub": str(user.id), "phone": user.phone}
    return TokenResponse(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data)
    )

@router.get("/me", response_model=UserResponse)
def get_current_user(
    authorization: str = Header(...),
    db: Session = Depends(get_db)
):
    token = authorization.replace("Bearer ", "")
    payload = decode_token(token)
    user_id = int(payload.get("sub"))
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user