from sqlalchemy import Column, String, Numeric, Integer, DateTime, Text
from models.base import BaseModel

class Fund(BaseModel):
    __tablename__ = "funds"

    fund_code = Column(String(10), unique=True, index=True, nullable=False)
    fund_name = Column(String(100), nullable=False)
    fund_type = Column(String(20), nullable=False)
    risk_level = Column(String(10), nullable=False)
    nav = Column(Numeric(10, 4), nullable=False)
    acc_nav = Column(Numeric(10, 4), nullable=False)
    min_purchase = Column(Numeric(10, 2), default=100.00)
    min_switch = Column(Numeric(10, 2), default=100.00)
    purchase_fee = Column(Numeric(5, 4), default=0.015)
    redeem_fee = Column(Numeric(5, 4), default=0.005)
    manager_name = Column(String(50), nullable=True)
    company_name = Column(String(100), nullable=True)
    description = Column(Text, nullable=True)
    status = Column(String(20), default="open")

class FundNavHistory(BaseModel):
    __tablename__ = "fund_nav_history"

    fund_code = Column(String(10), index=True, nullable=False)
    nav_date = Column(DateTime, nullable=False)
    nav = Column(Numeric(10, 4), nullable=False)
    acc_nav = Column(Numeric(10, 4), nullable=False)