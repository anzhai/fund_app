from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    phone: Optional[str] = Field(None, description="手机号")
    id_card: Optional[str] = Field(None, description="身份证号")
    password: str = Field(..., min_length=6, description="登录密码")
    user_type: str = Field("direct_sales", description="用户类型: direct_sales/agency")

class UserLogin(BaseModel):
    login_type: str = Field(..., description="登录类型: phone/id_card/sms/biometric")
    identifier: str = Field(..., description="标识符(手机号/身份证号)")
    password: Optional[str] = Field(None, description="密码(短信/生物识别登录时可选)")
    sms_code: Optional[str] = Field(None, description="短信验证码")
    biometric_token: Optional[str] = Field(None, description="生物识别token")

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900  # 15 minutes

class UserResponse(BaseModel):
    id: int
    phone: Optional[str]
    id_card: Optional[str]
    user_type: str
    risk_level: Optional[str]
    is_verified: bool
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class PasswordResetRequest(BaseModel):
    phone: str = Field(..., description="手机号")
    sms_code: str = Field(..., description="短信验证码")
    new_password: str = Field(..., min_length=6, description="新密码")
    confirm_password: str = Field(..., description="确认密码")

class SMSCodeRequest(BaseModel):
    phone: str = Field(..., description="手机号")
    purpose: str = Field("login", description="用途: login/register/reset_password")
