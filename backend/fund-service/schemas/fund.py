from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from decimal import Decimal

class FundBase(BaseModel):
    fund_code: str = Field(..., description="基金代码")
    fund_name: str = Field(..., description="基金名称")
    fund_type: str = Field(..., description="基金类型")
    risk_level: str = Field(..., description="风险等级")

class FundResponse(FundBase):
    id: int
    nav: Decimal = Field(..., description="单位净值")
    acc_nav: Decimal = Field(..., description="累计净值")
    min_purchase: Decimal = Field(..., description="最低购买金额")
    purchase_fee: Decimal = Field(..., description="申购费率")
    redeem_fee: Decimal = Field(..., description="赎回费率")
    manager_name: Optional[str] = Field(None, description="基金经理")
    company_name: Optional[str] = Field(None, description="基金公司")
    description: Optional[str] = Field(None, description="基金描述")
    status: str = Field(..., description="基金状态")
    created_at: datetime

    class Config:
        from_attributes = True

class FundDetailResponse(FundResponse):
    holdings: Optional[List[dict]] = Field(None, description="持仓信息")
    manager_info: Optional[dict] = Field(None, description="基金经理信息")
    fee_structure: Optional[dict] = Field(None, description="费率结构")

class FundNavHistoryResponse(BaseModel):
    fund_code: str
    nav_date: datetime
    nav: Decimal
    acc_nav: Decimal
    
    class Config:
        from_attributes = True

class FundRankingItem(FundResponse):
    performance: float = Field(..., description="收益率(%)")
