from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from decimal import Decimal
from database import get_db
from models.portfolio import Portfolio, PortfolioPosition
from schemas.portfolio import (
    PortfolioCreate, PortfolioResponse,
    PortfolioPositionCreate, PortfolioPositionResponse,
    PortfolioDetailResponse
)

router = APIRouter(prefix="/portfolio", tags=["组合"])

@router.get("/", response_model=List[PortfolioResponse])
def list_portfolios(user_id: int, db: Session = Depends(get_db)):
    return db.query(Portfolio).filter(Portfolio.user_id == user_id).all()

@router.post("/", response_model=PortfolioResponse)
def create_portfolio(portfolio_data: PortfolioCreate, user_id: int, db: Session = Depends(get_db)):
    portfolio = Portfolio(
        user_id=user_id,
        portfolio_name=portfolio_data.portfolio_name,
        description=portfolio_data.description
    )
    db.add(portfolio)
    db.commit()
    db.refresh(portfolio)
    return portfolio

@router.get("/{portfolio_id}", response_model=PortfolioDetailResponse)
def get_portfolio(portfolio_id: int, db: Session = Depends(get_db)):
    portfolio = db.query(Portfolio).filter(Portfolio.id == portfolio_id).first()
    if not portfolio:
        raise HTTPException(status_code=404, detail="Portfolio not found")

    positions = db.query(PortfolioPosition).filter(
        PortfolioPosition.portfolio_id == portfolio_id
    ).all()

    total_value = sum(p.current_amount for p in positions)

    return PortfolioDetailResponse(
        id=portfolio.id,
        user_id=portfolio.user_id,
        portfolio_name=portfolio.portfolio_name,
        description=portfolio.description,
        status=portfolio.status,
        created_at=portfolio.created_at,
        positions=positions,
        total_value=total_value,
        daily_gain=Decimal("0.00"),
        daily_gain_ratio=Decimal("0.00")
    )

@router.post("/{portfolio_id}/positions", response_model=PortfolioPositionResponse)
def add_position(
    portfolio_id: int,
    position_data: PortfolioPositionCreate,
    db: Session = Depends(get_db)
):
    position = PortfolioPosition(
        portfolio_id=portfolio_id,
        fund_code=position_data.fund_code,
        fund_name=position_data.fund_name,
        target_ratio=position_data.target_ratio,
        current_amount=position_data.initial_amount,
        current_shares=position_data.initial_amount
    )
    db.add(position)
    db.commit()
    db.refresh(position)
    return position