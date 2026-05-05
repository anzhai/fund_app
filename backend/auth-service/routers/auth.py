from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from database import get_db
from models.user import User
from schemas.user import (
    UserCreate, UserLogin, TokenResponse, UserResponse,
    PasswordResetRequest, SMSCodeRequest
)
from services.auth_service import (
    generate_salt, hash_password, verify_password,
    create_access_token, create_refresh_token, decode_token
)
import random

router = APIRouter(prefix="/auth", tags=["认证"])

# Mock SMS code storage (in production use Redis)
sms_codes = {}

def generate_sms_code():
    """生成6位随机验证码"""
    return f"{random.randint(100000, 999999)}"

@router.post("/register", response_model=TokenResponse)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """用户注册 - 支持手机号快速注册"""
    # Validate phone number format
    import re
    if not user_data.phone or not re.match(r'^1[3-9]\d{9}$', user_data.phone):
        raise HTTPException(status_code=400, detail="手机号格式不正确")
    
    # Check if user already exists by phone only
    existing = db.query(User).filter(User.phone == user_data.phone).first()
    if existing:
        raise HTTPException(status_code=400, detail="该手机号已注册，请直接登录")

    salt = generate_salt()
    user = User(
        phone=user_data.phone,
        id_card=user_data.id_card if user_data.id_card else None,
        password_hash=hash_password(user_data.password, salt),
        salt=salt,
        user_type=user_data.user_type,
        is_verified=False,
        is_active=True
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
    """用户登录 - 支持多种登录方式"""
    user = None
    
    # Phone + Password login
    if login_data.login_type == "phone":
        user = db.query(User).filter(User.phone == login_data.identifier).first()
    
    # ID Card + Password login
    elif login_data.login_type == "id_card":
        user = db.query(User).filter(User.id_card == login_data.identifier).first()
    
    # SMS Code login
    elif login_data.login_type == "sms":
        user = db.query(User).filter(User.phone == login_data.identifier).first()
        if user and login_data.sms_code:
            # Verify SMS code (mock - in production check against stored code)
            stored_code = sms_codes.get(login_data.identifier)
            if stored_code != login_data.sms_code:
                raise HTTPException(status_code=401, detail="验证码错误或已过期")
    
    else:
        raise HTTPException(status_code=400, detail="不支持的登录方式")
    
    if not user:
        raise HTTPException(status_code=401, detail="用户不存在")
    
    # Verify password for password-based login
    if login_data.login_type in ["phone", "id_card"]:
        if not login_data.password:
            raise HTTPException(status_code=400, detail="密码不能为空")
        if not verify_password(login_data.password, user.salt, user.password_hash):
            raise HTTPException(status_code=401, detail="密码错误")
    
    # Update last login info
    user.last_login_ip = "127.0.0.1"
    db.commit()

    token_data = {"sub": str(user.id), "phone": user.phone}
    return TokenResponse(
        access_token=create_access_token(token_data),
        refresh_token=create_refresh_token(token_data)
    )

@router.post("/sms/send")
def send_sms_code(sms_data: SMSCodeRequest):
    """发送短信验证码"""
    # Validate phone number format
    import re
    if not re.match(r'^1[3-9]\d{9}$', sms_data.phone):
        raise HTTPException(status_code=400, detail="手机号格式不正确")
    
    # Generate and store SMS code
    # In test environment, use fixed code 888888 for easier testing
    code = "888888"  # Fixed code for testing
    
    # For production, uncomment the following line and comment the fixed code
    # code = generate_sms_code()
    
    sms_codes[sms_data.phone] = code
    
    # Mock: Print code to console (in production send via SMS gateway)
    print(f"SMS Code for {sms_data.phone}: {code}")
    
    return {"message": "验证码已发送", "code": code, "expires_in": 300}  # 5 minutes

@router.post("/refresh", response_model=TokenResponse)
def refresh_token_endpoint(refresh_token: str, db: Session = Depends(get_db)):
    """刷新Access Token"""
    payload = decode_token(refresh_token)
    if payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="无效的Token类型")

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise HTTPException(status_code=401, detail="用户不存在")

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
    """获取当前用户信息"""
    try:
        token = authorization.replace("Bearer ", "")
        payload = decode_token(token)
        user_id = int(payload.get("sub"))
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="用户不存在")
        return user
    except Exception as e:
        raise HTTPException(status_code=401, detail="Token无效或已过期")

@router.post("/password/reset")
def reset_password(reset_data: PasswordResetRequest, db: Session = Depends(get_db)):
    """重置登录密码"""
    # Verify SMS code
    stored_code = sms_codes.get(reset_data.phone)
    if stored_code != reset_data.sms_code:
        raise HTTPException(status_code=400, detail="验证码错误")
    
    if reset_data.new_password != reset_data.confirm_password:
        raise HTTPException(status_code=400, detail="两次密码不一致")
    
    user = db.query(User).filter(User.phone == reset_data.phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    
    salt = generate_salt()
    user.password_hash = hash_password(reset_data.new_password, salt)
    user.salt = salt
    db.commit()
    
    return {"message": "密码重置成功"}
