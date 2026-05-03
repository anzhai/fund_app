from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from decimal import Decimal
from datetime import datetime, timedelta
from database import get_db
from models.trade import Wallet, WalletTransaction
from schemas.trade import RechargeRequest, WithdrawRequest, WalletResponse, TransactionHistoryResponse

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
    """充值 - 银行卡到钱包，实时到账"""
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
        remark=f"充值-银行卡{recharge_data.bank_card_id or '默认'}"
    )
    db.add(transaction)
    db.commit()
    return {"message": "充值成功", "balance": wallet.balance}

@wallet_router.post("/withdraw")
def withdraw(withdraw_data: WithdrawRequest, user_id: int, db: Session = Depends(get_db)):
    """取现 - 钱包到银行卡"""
    wallet = db.query(Wallet).filter(Wallet.user_id == user_id).first()
    if not wallet or wallet.balance < withdraw_data.amount:
        raise HTTPException(status_code=400, detail="余额不足")

    # Check withdrawal limits for fast withdrawal
    if withdraw_data.withdraw_type == "fast" and withdraw_data.amount > Decimal("10000"):
        raise HTTPException(status_code=400, detail="快速取现单笔限额1万元")

    wallet.balance -= withdraw_data.amount

    # Calculate arrival time
    if withdraw_data.withdraw_type == "fast":
        arrival_info = "实时到账"
    else:
        arrival_info = "T+1到账"

    transaction = WalletTransaction(
        user_id=user_id,
        wallet_id=wallet.id,
        amount=withdraw_data.amount,
        transaction_type="withdraw",
        remark=f"取现-{withdraw_data.withdraw_type}-{arrival_info}-卡{withdraw_data.bank_card_id or '默认'}"
    )
    db.add(transaction)
    db.commit()
    return {
        "message": f"取现申请成功 - {arrival_info}",
        "balance": wallet.balance,
        "arrival_info": arrival_info
    }

@wallet_router.get("/transactions", response_model=list[TransactionHistoryResponse])
def get_transactions(user_id: int, db: Session = Depends(get_db)):
    """查询钱包交易记录"""
    return db.query(WalletTransaction).filter(
        WalletTransaction.user_id == user_id
    ).order_by(WalletTransaction.created_at.desc()).all()
