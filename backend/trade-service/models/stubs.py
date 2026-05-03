from sqlalchemy import Column, String, Integer
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    phone = Column(String(11), unique=True, index=True, nullable=True)
    id_card = Column(String(18), unique=True, index=True, nullable=True)
    risk_level = Column(String(10), nullable=True)  # C1-C5
    is_active = Column(Integer, default=True)

class Fund(Base):
    __tablename__ = "funds"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    fund_code = Column(String(10), unique=True, index=True, nullable=False)
    fund_name = Column(String(100), nullable=False)
    fund_type = Column(String(20), nullable=False)
    risk_level = Column(String(10), nullable=False)  # R1-R5
    nav = Column(String(10), nullable=False)
    purchase_fee = Column(String(10), default="0.015")
    redeem_fee = Column(String(10), default="0.005")
    status = Column(String(20), default="open")