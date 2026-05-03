from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, DateTime
from models.base import BaseModel
from datetime import datetime

class TradeOrder(BaseModel):
    __tablename__ = "trade_orders"

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    fund_code = Column(String(10), nullable=False)
    fund_name = Column(String(100), nullable=False)
    trade_type = Column(String(20), nullable=False)
    amount = Column(Numeric(15, 2), nullable=False)
    shares = Column(Numeric(15, 4), nullable=True)
    nav = Column(Numeric(10, 4), nullable=True)
    fee = Column(Numeric(10, 2), default=0.00)
    status = Column(String(20), default="pending")
    pay_method = Column(String(20), nullable=False)
    target_fund_code = Column(String(10), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    confirmed_at = Column(DateTime, nullable=True)

class Wallet(BaseModel):
    __tablename__ = "wallets"

    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    balance = Column(Numeric(15, 2), default=0.00)
    frozen_balance = Column(Numeric(15, 2), default=0.00)

class WalletTransaction(BaseModel):
    __tablename__ = "wallet_transactions"

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    wallet_id = Column(Integer, ForeignKey("wallets.id"), nullable=False)
    amount = Column(Numeric(15, 2), nullable=False)
    transaction_type = Column(String(20), nullable=False)
    status = Column(String(20), default="completed")
    remark = Column(String(200), nullable=True)