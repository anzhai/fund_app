from sqlalchemy import Column, String, Integer, Date, Boolean, Text, DateTime
from models.base import BaseModel
from datetime import datetime

class BankCard(BaseModel):
    __tablename__ = "bank_cards"

    user_id = Column(Integer, nullable=False)  # References users.id (cross-service)
    bank_name = Column(String(50), nullable=False)
    bank_code = Column(String(20), nullable=False)
    card_number = Column(String(30), nullable=False)
    card_type = Column(String(20), default="储蓄卡")
    is_default = Column(Boolean, default=False)
    status = Column(String(20), default="active")

class Account(BaseModel):
    __tablename__ = "accounts"

    user_id = Column(Integer, unique=True, nullable=False)  # References users.id (cross-service)
    id_card = Column(String(18), nullable=False)
    id_card_type = Column(String(10), default="id_card")
    real_name = Column(String(50), nullable=False)
    id_card_expire = Column(Date, nullable=False)
    risk_level = Column(String(10), nullable=True)
    risk_expire_date = Column(Date, nullable=True)
    risk_status = Column(String(20), default="not_done")
    account_status = Column(String(20), default="pending")
    verification_status = Column(String(20), default="pending")

class RiskQuestionnaire(BaseModel):
    __tablename__ = "risk_questionnaires"

    user_id = Column(Integer, unique=True, nullable=False)
    answers = Column(Text, nullable=False)
    score = Column(Integer, default=0)
    risk_level = Column(String(10), nullable=True)
    expire_date = Column(Date, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)