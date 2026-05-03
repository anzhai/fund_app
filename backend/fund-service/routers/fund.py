from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta
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
    sort_by: Optional[str] = None,  # nav, performance_1m, performance_3m, performance_1y
    db: Session = Depends(get_db)
):
    """查询基金列表，支持筛选和排序"""
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
    
    # Sort by performance (mock data for now)
    if sort_by:
        if sort_by == "nav":
            query = query.order_by(Fund.nav.desc())
        # For performance sorting, we would need historical NAV data
        # For MVP, just return default order
    
    return query.all()

@router.get("/ranking", response_model=List[FundResponse])
def get_fund_ranking(
    period: str = Query("1m", description="排行周期: 1m, 3m, 6m, 1y, 3y"),
    fund_type: Optional[str] = None,
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """基金排行榜 - 按收益率排序"""
    query = db.query(Fund)
    
    if fund_type:
        query = query.filter(Fund.fund_type == fund_type)
    
    # For MVP, mock performance data based on acc_nav / nav ratio
    funds = query.all()
    
    # Calculate mock performance based on period
    def mock_performance(fund, period):
        # This is simplified - in production use actual historical NAV data
        base_return = float(fund.acc_nav - fund.nav) / float(fund.nav) * 100
        if period == "1m":
            return base_return * 0.1
        elif period == "3m":
            return base_return * 0.3
        elif period == "6m":
            return base_return * 0.5
        elif period == "1y":
            return base_return
        elif period == "3y":
            return base_return * 2.5
        return base_return
    
    # Add mock performance and sort
    funds_with_perf = [(fund, mock_performance(fund, period)) for fund in funds]
    funds_with_perf.sort(key=lambda x: x[1], reverse=True)
    
    return [fund for fund, _ in funds_with_perf[:limit]]

@router.get("/{fund_code}", response_model=FundResponse)
def get_fund(fund_code: str, db: Session = Depends(get_db)):
    """获取基金详情"""
    fund = db.query(Fund).filter(Fund.fund_code == fund_code).first()
    if not fund:
        raise HTTPException(status_code=404, detail="基金不存在")
    return fund

@router.get("/{fund_code}/nav-history", response_model=List[FundNavHistoryResponse])
def get_nav_history(
    fund_code: str,
    days: int = Query(30, ge=1, le=365),
    db: Session = Depends(get_db)
):
    """获取基金净值历史"""
    history = db.query(FundNavHistory).filter(
        FundNavHistory.fund_code == fund_code
    ).order_by(FundNavHistory.nav_date.desc()).limit(days).all()
    return history

@router.get("/{fund_code}/detail")
def get_fund_detail(fund_code: str, db: Session = Depends(get_db)):
    """获取基金详细信息（包括持仓、经理、费率等）"""
    fund = db.query(Fund).filter(Fund.fund_code == fund_code).first()
    if not fund:
        raise HTTPException(status_code=404, detail="基金不存在")
    
    # Mock detailed information
    return {
        "fund": fund,
        "holdings": [
            {"stock_code": "600519", "stock_name": "贵州茅台", "ratio": 8.5},
            {"stock_code": "000858", "stock_name": "五粮液", "ratio": 6.2},
        ],
        "manager_info": {
            "name": fund.manager_name,
            "experience_years": 8,
            "managed_funds": 5
        },
        "fee_structure": {
            "purchase_fee": float(fund.purchase_fee),
            "redeem_fee": float(fund.redeem_fee),
            "management_fee": 0.015,
            "custodian_fee": 0.0025
        }
    }

@router.post("/seed")
def seed_mock_data(db: Session = Depends(get_db)):
    """初始化Mock基金数据"""
    for fund_data in MOCK_FUNDS:
        existing = db.query(Fund).filter(Fund.fund_code == fund_data["fund_code"]).first()
        if not existing:
            fund = Fund(**fund_data)
            db.add(fund)
    db.commit()
    return {"message": f"成功导入{len(MOCK_FUNDS)}只基金数据"}
