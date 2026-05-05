from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from decimal import Decimal
from datetime import datetime, timedelta
from database import get_db
from models.trade import TradeOrder, Wallet, SIPPlan
from schemas.trade import (
    PurchaseRequest, RedeemRequest, SubscribeRequest, SwitchRequest,
    CancelOrderRequest, DividendReinvestRequest,
    CreateSIPRequest, UpdateSIPRequest,
    TradeOrderResponse, SIPPlanResponse
)
from services.risk_service import check_amount_limit
import httpx

router = APIRouter(prefix="/trade", tags=["交易"])

AUTH_SERVICE_URL = "http://auth-service:8001/auth"

async def get_user_id_from_token(authorization: str = Header(...)) -> int:
    """Extract user_id from auth token by calling auth service"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{AUTH_SERVICE_URL}/me",
                headers={"Authorization": authorization}
            )
            if response.status_code == 200:
                user_data = response.json()
                return user_data["id"]
            raise HTTPException(status_code=401, detail="Invalid token")
    except Exception as e:
        raise HTTPException(status_code=401, detail="Authentication failed")

def get_wallet_or_create(db: Session, user_id: int) -> Wallet:
    wallet = db.query(Wallet).filter(Wallet.user_id == user_id).first()
    if not wallet:
        wallet = Wallet(user_id=user_id, balance=Decimal("0.00"))
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
    return wallet

@router.post("/purchase", response_model=TradeOrderResponse)
async def purchase(purchase_data: PurchaseRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    # Note: In production, fetch fund from fund-service via REST call
    # For MVP, we assume fund exists and risk check passes

    can_purchase, msg = check_amount_limit(purchase_data.amount)
    if not can_purchase:
        raise HTTPException(status_code=400, detail=msg)

    # Calculate shares and fee (simplified - in production get from fund-service)
    nav = Decimal("1.0000")  # Mock NAV
    fee_rate = Decimal("0.015")  # Mock fee rate
    shares = purchase_data.amount / nav
    fee = purchase_data.amount * fee_rate

    wallet = get_wallet_or_create(db, user_id)
    total_amount = purchase_data.amount + fee
    if purchase_data.pay_method == "wallet" and wallet.balance < total_amount:
        raise HTTPException(status_code=400, detail="钱包余额不足")

    if purchase_data.pay_method == "wallet":
        wallet.balance -= total_amount

    order = TradeOrder(
        user_id=user_id,
        fund_code=purchase_data.fund_code,
        fund_name=f"基金{purchase_data.fund_code}",
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
async def redeem(redeem_data: RedeemRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    nav = Decimal("1.0000")  # Mock NAV
    fee_rate = Decimal("0.005")  # Mock fee rate
    amount = redeem_data.shares * nav
    fee = amount * fee_rate

    order = TradeOrder(
        user_id=user_id,
        fund_code=redeem_data.fund_code,
        fund_name=f"基金{redeem_data.fund_code}",
        trade_type="redeem",
        amount=amount,
        shares=redeem_data.shares,
        nav=nav,
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

@router.post("/subscribe", response_model=TradeOrderResponse)
async def subscribe(subscribe_data: SubscribeRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """认购新基金"""
    can_purchase, msg = check_amount_limit(subscribe_data.amount)
    if not can_purchase:
        raise HTTPException(status_code=400, detail=msg)

    nav = Decimal("1.0000")
    fee_rate = Decimal("0.012")
    shares = subscribe_data.amount / nav
    fee = subscribe_data.amount * fee_rate

    wallet = get_wallet_or_create(db, user_id)
    total_amount = subscribe_data.amount + fee
    if subscribe_data.pay_method == "wallet" and wallet.balance < total_amount:
        raise HTTPException(status_code=400, detail="钱包余额不足")

    if subscribe_data.pay_method == "wallet":
        wallet.balance -= total_amount

    order = TradeOrder(
        user_id=user_id,
        fund_code=subscribe_data.fund_code,
        fund_name=f"新基金{subscribe_data.fund_code}",
        trade_type="subscribe",
        amount=subscribe_data.amount,
        shares=shares,
        nav=nav,
        fee=fee,
        status="confirmed",
        pay_method=subscribe_data.pay_method,
        confirmed_at=datetime.utcnow()
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order

@router.post("/switch", response_model=TradeOrderResponse)
async def switch_fund(switch_data: SwitchRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """基金转换"""
    nav = Decimal("1.0000")
    fee_rate = Decimal("0.003")
    shares = switch_data.amount / nav
    fee = switch_data.amount * fee_rate

    order = TradeOrder(
        user_id=user_id,
        fund_code=switch_data.source_fund_code,
        fund_name=f"基金{switch_data.source_fund_code}",
        trade_type="switch",
        amount=switch_data.amount,
        shares=shares,
        nav=nav,
        fee=fee,
        status="confirmed",
        pay_method=switch_data.pay_method,
        target_fund_code=switch_data.target_fund_code,
        confirmed_at=datetime.utcnow()
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order

@router.post("/cancel", response_model=TradeOrderResponse)
async def cancel_order(cancel_data: CancelOrderRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """撤单"""
    order = db.query(TradeOrder).filter(
        TradeOrder.id == cancel_data.order_id,
        TradeOrder.user_id == user_id,
        TradeOrder.status == "pending"
    ).first()

    if not order:
        raise HTTPException(status_code=404, detail="订单不存在或已成交")

    order.status = "cancelled"
    db.commit()
    db.refresh(order)
    return order

@router.post("/dividend-reinvest", response_model=TradeOrderResponse)
async def dividend_reinvest(dividend_data: DividendReinvestRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """红利再投"""
    nav = Decimal("1.0000")
    shares = dividend_data.dividend_amount / nav

    order = TradeOrder(
        user_id=user_id,
        fund_code=dividend_data.fund_code,
        fund_name=f"基金{dividend_data.fund_code}",
        trade_type="dividend_reinvest",
        amount=dividend_data.dividend_amount,
        shares=shares,
        nav=nav,
        fee=Decimal("0.00"),
        status="confirmed",
        pay_method="dividend",
        confirmed_at=datetime.utcnow()
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order

# SIP (定投) endpoints
@router.post("/sip/create", response_model=SIPPlanResponse)
async def create_sip_plan(sip_data: CreateSIPRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """创建定投计划"""
    # Calculate next deduction date
    now = datetime.utcnow()
    if sip_data.frequency == "monthly":
        next_date = now.replace(day=min(sip_data.day_of_period, 28))
        if next_date <= now:
            next_date = (next_date.replace(day=1) + timedelta(days=32)).replace(day=min(sip_data.day_of_period, 28))
    else:
        next_date = now + timedelta(days=7)

    plan = SIPPlan(
        user_id=user_id,
        fund_code=sip_data.fund_code,
        fund_name=f"基金{sip_data.fund_code}",
        amount=sip_data.amount,
        frequency=sip_data.frequency,
        day_of_period=sip_data.day_of_period,
        start_date=sip_data.start_date,
        end_date=sip_data.end_date,
        next_deduction_date=next_date,
        status="active",
        sip_type=sip_data.sip_type,
        pay_method=sip_data.pay_method
    )
    db.add(plan)
    db.commit()
    db.refresh(plan)
    return plan

@router.get("/sip/list", response_model=list[SIPPlanResponse])
async def list_sip_plans(user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """查询定投计划列表"""
    return db.query(SIPPlan).filter(SIPPlan.user_id == user_id).all()

@router.put("/sip/{plan_id}", response_model=SIPPlanResponse)
async def update_sip_plan(plan_id: int, update_data: UpdateSIPRequest, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """修改定投计划"""
    plan = db.query(SIPPlan).filter(SIPPlan.id == plan_id, SIPPlan.user_id == user_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="定投计划不存在")

    if update_data.amount is not None:
        plan.amount = update_data.amount
    if update_data.frequency is not None:
        plan.frequency = update_data.frequency
    if update_data.day_of_period is not None:
        plan.day_of_period = update_data.day_of_period
    if update_data.status is not None:
        plan.status = update_data.status

    db.commit()
    db.refresh(plan)
    return plan

@router.delete("/sip/{plan_id}")
async def terminate_sip_plan(plan_id: int, user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """终止定投计划"""
    plan = db.query(SIPPlan).filter(SIPPlan.id == plan_id, SIPPlan.user_id == user_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="定投计划不存在")

    plan.status = "terminated"
    db.commit()
    return {"message": "定投计划已终止"}

@router.get("/orders", response_model=list[TradeOrderResponse])
async def list_orders(user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """查询交易记录"""
    return db.query(TradeOrder).filter(TradeOrder.user_id == user_id).order_by(TradeOrder.created_at.desc()).all()