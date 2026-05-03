from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from decimal import Decimal

class PortfolioCreate(BaseModel):
    portfolio_name: str
    description: Optional[str] = None

class PortfolioPositionCreate(BaseModel):
    fund_code: str
    fund_name: str
    target_ratio: Decimal
    initial_amount: Decimal

class PortfolioResponse(BaseModel):
    id: int
    user_id: int
    portfolio_name: str
    description: Optional[str]
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class PortfolioPositionResponse(BaseModel):
    id: int
    portfolio_id: int
    fund_code: str
    fund_name: str
    target_ratio: Decimal
    current_amount: Decimal
    current_shares: Decimal
    nav: Decimal
    status: str

    class Config:
        from_attributes = True

class PortfolioDetailResponse(PortfolioResponse):
    positions: List[PortfolioPositionResponse]
    total_value: Decimal
    daily_gain: Decimal
    daily_gain_ratio: Decimal