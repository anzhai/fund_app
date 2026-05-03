from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, date, timedelta
from database import get_db
from models.account import Account, BankCard
from schemas.account import AccountCreate, BankCardAdd
from services.validation_service import validate_id_card, validate_id_card_expire, validate_trade_password

router = APIRouter(prefix="/account", tags=["开户"])

@router.post("/open")
def open_account(account_data: AccountCreate, user_id: int, db: Session = Depends(get_db)):
    valid, msg = validate_id_card(account_data.id_card)
    if not valid:
        raise HTTPException(status_code=400, detail=msg)

    valid, msg = validate_id_card_expire(account_data.id_card_expire)
    if not valid:
        raise HTTPException(status_code=400, detail=msg)

    valid, msg = validate_trade_password(account_data.trade_password, account_data.id_card, "")
    if not valid:
        raise HTTPException(status_code=400, detail=msg)

    existing = db.query(Account).filter(Account.user_id == user_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="账户已开通")

    account = Account(
        user_id=user_id,
        id_card=account_data.id_card,
        real_name=account_data.real_name,
        id_card_expire=account_data.id_card_expire,
        account_status="active",
        verification_status="verified"
    )
    db.add(account)
    db.commit()
    db.refresh(account)

    return {"message": "开户成功", "account_id": account.id}

@router.post("/bank-card")
def add_bank_card(card_data: BankCardAdd, user_id: int, db: Session = Depends(get_db)):
    card = BankCard(
        user_id=user_id,
        bank_name=card_data.bank_name,
        bank_code=card_data.bank_code,
        card_number=card_data.card_number,
        is_default=card_data.is_default
    )
    db.add(card)
    db.commit()
    db.refresh(card)
    return {"message": "银行卡添加成功", "card_id": card.id}