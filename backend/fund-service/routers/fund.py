from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from database import get_db
from models.fund import Fund, FundNavHistory
from schemas.fund import FundResponse, FundNavHistoryResponse
from services.mock_data import MOCK_FUNDS

router = APIRouter(prefix="/fund", tags=["基金"])

@router.get("/", response_model=List[FundResponse])
def list_funds(
    fund_type: Optional[str] = None,
    risk_level: Optional[str] = None,
    keyword: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Fund)
    if fund_type:
        query = query.filter(Fund.fund_type == fund_type)
    if risk_level:
        query = query.filter(Fund.risk_level == risk_level)
    if keyword:
        query = query.filter(
            (Fund.fund_name.like(f"%{keyword}%")) |
            (Fund.fund_code.like(f"%{keyword}%"))
        )
    return query.all()

@router.get("/{fund_code}", response_model=FundResponse)
def get_fund(fund_code: str, db: Session = Depends(get_db)):
    fund = db.query(Fund).filter(Fund.fund_code == fund_code).first()
    if not fund:
        raise HTTPException(status_code=404, detail="Fund not found")
    return fund

@router.get("/{fund_code}/nav-history", response_model=List[FundNavHistoryResponse])
def get_nav_history(
    fund_code: str,
    days: int = Query(30, ge=1, le=365),
    db: Session = Depends(get_db)
):
    history = db.query(FundNavHistory).filter(
        FundNavHistory.fund_code == fund_code
    ).order_by(FundNavHistory.nav_date.desc()).limit(days).all()
    return history

@router.post("/seed")
def seed_mock_data(db: Session = Depends(get_db)):
    for fund_data in MOCK_FUNDS:
        existing = db.query(Fund).filter(Fund.fund_code == fund_data["fund_code"]).first()
        if not existing:
            fund = Fund(**fund_data)
            db.add(fund)
    db.commit()
    return {"message": "Mock data seeded"}