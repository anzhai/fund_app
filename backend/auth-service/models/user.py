from sqlalchemy import Column, String, Integer, Boolean, DateTime
from datetime import datetime
from models.base import BaseModel

class User(BaseModel):
    __tablename__ = "users"

    phone = Column(String(11), unique=True, index=True, nullable=True)
    id_card = Column(String(18), unique=True, index=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    salt = Column(String(32), nullable=False)
    user_type = Column(String(20), default="direct_sales")
    id_card_type = Column(String(10), default="id_card")
    risk_level = Column(String(10), nullable=True)
    risk_expire_date = Column(DateTime, nullable=True)
    is_verified = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    last_login_device = Column(String(100), nullable=True)
    last_login_ip = Column(String(45), nullable=True)