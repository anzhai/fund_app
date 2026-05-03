from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from decimal import Decimal
from datetime import datetime
from database import get_db
from models.trade import TradeOrder, Wallet
from models.user import User
from models.fund import Fund
from schemas.trade import (
    PurchaseRequest, RedeemRequest, TradeOrderResponse
)
from services.risk_service import check_risk_match, check_amount_limit

router = APIRouter(prefix="/trade", tags=["交易"])

def get_wallet_or_create(db: Session, user_id: int) -> Wallet:
    wallet = db.query(Wallet).filter(Wallet.user_id == user_id).first()
    if not wallet:
        wallet = Wallet(user_id=user_id, balance=Decimal("0.00"))
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
    return wallet

@router.post("/purchase", response_model=TradeOrderResponse)
def purchase(purchase_data: PurchaseRequest, user_id: int, db: Session = Depends(get_db)):
    fund = db.query(Fund).filter(Fund.fund_code == purchase_data.fund_code).first()
    if not fund:
        raise HTTPException(status_code=404, detail="基金不存在")

    user = db.query(User).filter(User.id == user_id).first()

    can_purchase, msg = check_risk_match(user.risk_level if user else None, fund.risk_level)
    if not can_purchase:
        raise HTTPException(status_code=400, detail=f"风险不匹配: {msg}")

    can_purchase, msg = check_amount_limit(purchase_data.amount)
    if not can_purchase:
        raise HTTPException(status_code=400, detail=msg)

    nav = fund.nav
    shares = purchase_data.amount / nav
    fee = purchase_data.amount * fund.purchase_fee

    wallet = get_wallet_or_create(db, user_id)
    total_amount = purchase_data.amount + fee
    if purchase_data.pay_method == "wallet" and wallet.balance < total_amount:
        raise HTTPException(status_code=400, detail="钱包余额不足")

    if purchase_data.pay_method == "wallet":
        wallet.balance -= total_amount

    order = TradeOrder(
        user_id=user_id,
        fund_code=fund.fund_code,
        fund_name=fund.fund_name,
        trade_type="purchase",
        amount=purchase_data.amount,
        shares=shares,
        nav=nav,
        fee=fee,
        status="confirmed",
        pay_method=purchase_data.pay_method,
        confirmed_at=datetime.utcnow()
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order

@router.post("/redeem", response_model=TradeOrderResponse)
def redeem(redeem_data: RedeemRequest, user_id: int, db: Session = Depends(get_db)):
    fund = db.query(Fund).filter(Fund.fund_code == redeem_data.fund_code).first()
    if not fund:
        raise HTTPException(status_code=404, detail="基金不存在")

    amount = redeem_data.shares * fund.nav
    fee = amount * fund.redeem_fee

    order = TradeOrder(
        user_id=user_id,
        fund_code=fund.fund_code,
        fund_name=fund.fund_name,
        trade_type="redeem",
        amount=amount,
        shares=redeem_data.shares,
        nav=fund.nav,
        fee=fee,
        status="confirmed",
        pay_method=redeem_data.redeem_to,
        confirmed_at=datetime.utcnow()
    )
    db.add(order)

    if redeem_data.redeem_to == "wallet":
        wallet = get_wallet_or_create(db, user_id)
        wallet.balance += (amount - fee)

    db.commit()
    db.refresh(order)
    return order

@router.get("/orders", response_model=list[TradeOrderResponse])
def list_orders(user_id: int, db: Session = Depends(get_db)):
    return db.query(TradeOrder).filter(TradeOrder.user_id == user_id).order_by(TradeOrder.created_at.desc()).all()