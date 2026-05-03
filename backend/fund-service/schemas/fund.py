from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from decimal import Decimal

class FundBase(BaseModel):
    fund_code: str
    fund_name: str
    fund_type: str
    risk_level: str

class FundResponse(FundBase):
    id: int
    nav: Decimal
    acc_nav: Decimal
    min_purchase: Decimal
    purchase_fee: Decimal
    redeem_fee: Decimal
    manager_name: Optional[str]
    company_name: Optional[str]
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class FundNavHistoryResponse(BaseModel):
    fund_code: str
    nav_date: datetime
    nav: Decimal
    acc_nav: Decimal