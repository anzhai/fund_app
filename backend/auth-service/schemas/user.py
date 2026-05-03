from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    phone: Optional[str] = None
    id_card: Optional[str] = None
    password: str
    user_type: str = "direct_sales"

class UserLogin(BaseModel):
    login_type: str
    identifier: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class UserResponse(BaseModel):
    id: int
    phone: Optional[str]
    id_card: Optional[str]
    user_type: str
    risk_level: Optional[str]
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True