from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from decimal import Decimal

class PurchaseRequest(BaseModel):
    fund_code: str
    amount: Decimal = Field(..., gt=0, description="购买金额")
    pay_method: str = "wallet"  # wallet or bank_card

class RedeemRequest(BaseModel):
    fund_code: str
    shares: Decimal = Field(..., gt=0, description="赎回份额")
    redeem_to: str = "wallet"  # wallet, bank_card

class SubscribeRequest(BaseModel):
    fund_code: str
    amount: Decimal = Field(..., gt=0, description="认购金额")
    pay_method: str = "wallet"

class SwitchRequest(BaseModel):
    source_fund_code: str
    target_fund_code: str
    amount: Decimal = Field(..., gt=0, description="转换金额")
    pay_method: str = "wallet"

class CancelOrderRequest(BaseModel):
    order_id: int

class DividendReinvestRequest(BaseModel):
    fund_code: str
    dividend_amount: Decimal = Field(..., gt=0, description="分红金额")

# SIP (Systematic Investment Plan) - 定投相关
class CreateSIPRequest(BaseModel):
    fund_code: str
    amount: Decimal = Field(..., gt=0, description="定投金额")
    frequency: str = "monthly"  # daily, weekly, biweekly, monthly
    day_of_period: int = Field(..., ge=1, le=31, description="扣款日")
    start_date: datetime
    end_date: Optional[datetime] = None
    pay_method: str = "wallet"
    sip_type: str = "regular"  # regular(普通定投), salary(工资理财)

class UpdateSIPRequest(BaseModel):
    amount: Optional[Decimal] = Field(None, gt=0)
    frequency: Optional[str] = None
    day_of_period: Optional[int] = Field(None, ge=1, le=31)
    status: Optional[str] = None  # active, paused, terminated

class TradeOrderResponse(BaseModel):
    id: int
    user_id: int
    fund_code: str
    fund_name: str
    trade_type: str  # purchase, redeem, subscribe, switch, cancel, dividend_reinvest
    amount: Decimal
    shares: Optional[Decimal]
    nav: Optional[Decimal]
    fee: Decimal
    status: str  # pending, confirmed, cancelled, failed
    pay_method: str
    target_fund_code: Optional[str] = None
    created_at: datetime
    confirmed_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class SIPPlanResponse(BaseModel):
    id: int
    user_id: int
    fund_code: str
    fund_name: str
    amount: Decimal
    frequency: str
    day_of_period: int
    start_date: datetime
    end_date: Optional[datetime]
    next_deduction_date: datetime
    status: str  # active, paused, terminated, completed
    sip_type: str  # regular, salary
    total_invested: Decimal
    total_shares: Decimal
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class RechargeRequest(BaseModel):
    amount: Decimal = Field(..., gt=0, description="充值金额")
    bank_card_id: Optional[int] = None

class WithdrawRequest(BaseModel):
    amount: Decimal = Field(..., gt=0, description="取现金额")
    withdraw_type: str = "normal"  # normal(T+1), fast(实时)
    bank_card_id: Optional[int] = None

class WalletResponse(BaseModel):
    id: int
    user_id: int
    balance: Decimal
    frozen_balance: Decimal

    class Config:
        from_attributes = True

class TransactionHistoryResponse(BaseModel):
    id: int
    user_id: int
    wallet_id: int
    amount: Decimal
    transaction_type: str  # recharge, withdraw, purchase, redeem, dividend
    status: str
    remark: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
