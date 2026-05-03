from sqlalchemy import Column, String, Numeric, Integer
from models.base import BaseModel

class Portfolio(BaseModel):
    __tablename__ = "portfolios"

    user_id = Column(Integer, nullable=False)  # References users.id from auth-service
    portfolio_name = Column(String(100), nullable=False)
    description = Column(String(500), nullable=True)
    status = Column(String(20), default="active")

class PortfolioPosition(BaseModel):
    __tablename__ = "portfolio_positions"

    portfolio_id = Column(Integer, nullable=False)  # References portfolios.id
    fund_code = Column(String(10), nullable=False)
    fund_name = Column(String(100), nullable=False)
    target_ratio = Column(Numeric(5, 4), nullable=False)
    current_amount = Column(Numeric(15, 2), default=0.00)
    current_shares = Column(Numeric(15, 4), default=0.00)
    nav = Column(Numeric(10, 4), default=1.0000)
    status = Column(String(20), default="active")