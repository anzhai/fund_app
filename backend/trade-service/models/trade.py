from sqlalchemy import Column, String, Numeric, Integer, DateTime, Text, Boolean
from models.base import BaseModel
from datetime import datetime

class TradeOrder(BaseModel):
    __tablename__ = "trade_orders"

    user_id = Column(Integer, nullable=False)  # References users.id (cross-service)
    fund_code = Column(String(10), nullable=False)
    fund_name = Column(String(100), nullable=False)
    trade_type = Column(String(30), nullable=False)  # purchase, redeem, subscribe, switch, cancel, dividend_reinvest
    amount = Column(Numeric(15, 2), nullable=False)
    shares = Column(Numeric(15, 4), nullable=True)
    nav = Column(Numeric(10, 4), nullable=True)
    fee = Column(Numeric(10, 2), default=0.00)
    status = Column(String(20), default="pending")  # pending, confirmed, cancelled, failed
    pay_method = Column(String(20), nullable=False)  # wallet, bank_card
    target_fund_code = Column(String(10), nullable=True)  # For switch trades
    sip_plan_id = Column(Integer, nullable=True)  # Reference to SIP plan if created by SIP
    created_at = Column(DateTime, default=datetime.utcnow)
    confirmed_at = Column(DateTime, nullable=True)

class Wallet(BaseModel):
    __tablename__ = "wallets"

    user_id = Column(Integer, unique=True, nullable=False)  # References users.id (cross-service)
    balance = Column(Numeric(15, 2), default=0.00)
    frozen_balance = Column(Numeric(15, 2), default=0.00)

class WalletTransaction(BaseModel):
    __tablename__ = "wallet_transactions"

    user_id = Column(Integer, nullable=False)
    wallet_id = Column(Integer, nullable=False)
    amount = Column(Numeric(15, 2), nullable=False)
    transaction_type = Column(String(20), nullable=False)  # recharge, withdraw, purchase, redeem, dividend
    status = Column(String(20), default="completed")
    remark = Column(String(200), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class SIPPlan(BaseModel):
    __tablename__ = "sip_plans"

    user_id = Column(Integer, nullable=False)
    fund_code = Column(String(10), nullable=False)
    fund_name = Column(String(100), nullable=False)
    amount = Column(Numeric(15, 2), nullable=False)
    frequency = Column(String(20), nullable=False)  # daily, weekly, biweekly, monthly
    day_of_period = Column(Integer, nullable=False)  # Day of month/week
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=True)
    next_deduction_date = Column(DateTime, nullable=False)
    status = Column(String(20), default="active")  # active, paused, terminated, completed
    sip_type = Column(String(20), default="regular")  # regular(普通定投), salary(工资理财)
    total_invested = Column(Numeric(15, 2), default=0.00)
    total_shares = Column(Numeric(15, 4), default=0.00)
    pay_method = Column(String(20), default="wallet")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
