from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal

class PurchaseRequest(BaseModel):
    fund_code: str
    amount: Decimal
    pay_method: str = "wallet"

class RedeemRequest(BaseModel):
    fund_code: str
    shares: Decimal
    redeem_to: str = "wallet"

class SubscribeRequest(BaseModel):
    fund_code: str
    amount: Decimal
    pay_method: str = "wallet"

class SwitchRequest(BaseModel):
    source_fund_code: str
    target_fund_code: str
    amount: Decimal
    pay_method: str = "wallet"

class TradeOrderResponse(BaseModel):
    id: int
    user_id: int
    fund_code: str
    fund_name: str
    trade_type: str
    amount: Decimal
    shares: Optional[Decimal]
    nav: Optional[Decimal]
    fee: Decimal
    status: str
    pay_method: str
    created_at: datetime

    class Config:
        from_attributes = True

class RechargeRequest(BaseModel):
    amount: Decimal

class WithdrawRequest(BaseModel):
    amount: Decimal
    withdraw_type: str = "normal"

class WalletResponse(BaseModel):
    id: int
    user_id: int
    balance: Decimal
    frozen_balance: Decimal

    class Config:
        from_attributes = True