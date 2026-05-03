from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, date, timedelta
from database import get_db
from models.account import Account, BankCard
from schemas.account import (
    AccountCreate, BankCardAdd, AccountResponse, BankCardResponse,
    PasswordResetRequest, TradePasswordResetRequest
)
from services.validation_service import (
    validate_id_card, validate_id_card_expire, validate_trade_password,
    validate_bank_card
)

router = APIRouter(prefix="/account", tags=["开户"])

@router.post("/open")
def open_account(account_data: AccountCreate, user_id: int, db: Session = Depends(get_db)):
    """开户 - 上传证件、设置交易密码"""
    # Validate ID card
    valid, msg = validate_id_card(account_data.id_card)
    if not valid:
        raise HTTPException(status_code=400, detail=msg)

    # Validate ID card expiration
    valid, msg = validate_id_card_expire(account_data.id_card_expire)
    if not valid:
        raise HTTPException(status_code=400, detail=msg)

    # Validate trade password strength
    valid, msg = validate_trade_password(account_data.trade_password, account_data.id_card, "")
    if not valid:
        raise HTTPException(status_code=400, detail=msg)

    # Check if account already exists
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

@router.get("/info", response_model=AccountResponse)
def get_account_info(user_id: int, db: Session = Depends(get_db)):
    """获取账户信息"""
    account = db.query(Account).filter(Account.user_id == user_id).first()
    if not account:
        raise HTTPException(status_code=404, detail="账户未开通")
    return account

@router.post("/bank-card")
def add_bank_card(card_data: BankCardAdd, user_id: int, db: Session = Depends(get_db)):
    """添加银行卡"""
    # Validate bank card number
    valid, msg = validate_bank_card(card_data.card_number)
    if not valid:
        raise HTTPException(status_code=400, detail=msg)

    # If this is the first card or marked as default, set other cards to non-default
    if card_data.is_default:
        db.query(BankCard).filter(
            BankCard.user_id == user_id,
            BankCard.is_default == True
        ).update({"is_default": False})

    card = BankCard(
        user_id=user_id,
        bank_name=card_data.bank_name,
        bank_code=card_data.bank_code,
        card_number=card_data.card_number,
        card_type=card_data.card_type,
        is_default=card_data.is_default
    )
    db.add(card)
    db.commit()
    db.refresh(card)
    return {"message": "银行卡添加成功", "card_id": card.id}

@router.get("/bank-cards", response_model=list[BankCardResponse])
def list_bank_cards(user_id: int, db: Session = Depends(get_db)):
    """查询银行卡列表"""
    return db.query(BankCard).filter(BankCard.user_id == user_id).all()

@router.delete("/bank-card/{card_id}")
def delete_bank_card(card_id: int, user_id: int, db: Session = Depends(get_db)):
    """删除银行卡"""
    card = db.query(BankCard).filter(
        BankCard.id == card_id,
        BankCard.user_id == user_id
    ).first()
    
    if not card:
        raise HTTPException(status_code=404, detail="银行卡不存在")
    
    db.delete(card)
    db.commit()
    return {"message": "银行卡删除成功"}

@router.put("/bank-card/{card_id}/default")
def set_default_card(card_id: int, user_id: int, db: Session = Depends(get_db)):
    """设置默认银行卡"""
    card = db.query(BankCard).filter(
        BankCard.id == card_id,
        BankCard.user_id == user_id
    ).first()
    
    if not card:
        raise HTTPException(status_code=404, detail="银行卡不存在")
    
    # Set all other cards to non-default
    db.query(BankCard).filter(
        BankCard.user_id == user_id,
        BankCard.is_default == True
    ).update({"is_default": False})
    
    card.is_default = True
    db.commit()
    return {"message": "默认卡设置成功"}

@router.post("/password/reset-login")
def reset_login_password(reset_data: PasswordResetRequest, db: Session = Depends(get_db)):
    """重置登录密码"""
    from auth_service.models.user import User
    from auth_service.services.auth_service import generate_salt, hash_password
    
    # Verify SMS code (mock - in production verify with SMS service)
    if reset_data.sms_code != "123456":  # Mock validation
        raise HTTPException(status_code=400, detail="验证码错误")
    
    if reset_data.new_password != reset_data.confirm_password:
        raise HTTPException(status_code=400, detail="两次密码不一致")
    
    user = db.query(User).filter(User.phone == reset_data.phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    
    salt = generate_salt()
    user.password_hash = hash_password(reset_data.new_password, salt)
    user.salt = salt
    db.commit()
    
    return {"message": "登录密码重置成功"}

@router.post("/password/reset-trade")
def reset_trade_password(reset_data: TradePasswordResetRequest, db: Session = Depends(get_db)):
    """重置交易密码"""
    # Verify SMS code (mock)
    if reset_data.sms_code != "123456":
        raise HTTPException(status_code=400, detail="验证码错误")
    
    if reset_data.new_password != reset_data.confirm_password:
        raise HTTPException(status_code=400, detail="两次密码不一致")
    
    # Validate new password
    valid, msg = validate_trade_password(reset_data.new_password, reset_data.id_card, reset_data.phone)
    if not valid:
        raise HTTPException(status_code=400, detail=msg)
    
    # In production, store trade password hash in account service
    # For MVP, just return success
    return {"message": "交易密码重置成功"}
