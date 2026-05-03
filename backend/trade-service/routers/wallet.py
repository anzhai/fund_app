from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from decimal import Decimal
from database import get_db
from models.trade import Wallet, WalletTransaction
from schemas.trade import RechargeRequest, WithdrawRequest, WalletResponse

wallet_router = APIRouter(prefix="/wallet", tags=["钱包"])

@wallet_router.get("/", response_model=WalletResponse)
def get_wallet(user_id: int, db: Session = Depends(get_db)):
    wallet = db.query(Wallet).filter(Wallet.user_id == user_id).first()
    if not wallet:
        wallet = Wallet(user_id=user_id, balance=Decimal("0.00"))
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
    return wallet

@wallet_router.post("/recharge")
def recharge(recharge_data: RechargeRequest, user_id: int, db: Session = Depends(get_db)):
    wallet = db.query(Wallet).filter(Wallet.user_id == user_id).first()
    if not wallet:
        wallet = Wallet(user_id=user_id, balance=Decimal("0.00"))
        db.add(wallet)

    wallet.balance += recharge_data.amount

    transaction = WalletTransaction(
        user_id=user_id,
        wallet_id=wallet.id,
        amount=recharge_data.amount,
        transaction_type="recharge",
        remark="充值"
    )
    db.add(transaction)
    db.commit()
    return {"message": "充值成功", "balance": wallet.balance}

@wallet_router.post("/withdraw")
def withdraw(withdraw_data: WithdrawRequest, user_id: int, db: Session = Depends(get_db)):
    wallet = db.query(Wallet).filter(Wallet.user_id == user_id).first()
    if not wallet or wallet.balance < withdraw_data.amount:
        raise HTTPException(status_code=400, detail="余额不足")

    wallet.balance -= withdraw_data.amount

    transaction = WalletTransaction(
        user_id=user_id,
        wallet_id=wallet.id,
        amount=withdraw_data.amount,
        transaction_type="withdraw",
        remark=f"取现-{withdraw_data.withdraw_type}"
    )
    db.add(transaction)
    db.commit()
    return {"message": "取现申请成功", "balance": wallet.balance}