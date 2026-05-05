from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from datetime import date, timedelta
from database import get_db
from models.account import RiskQuestionnaire, Account
from schemas.account import RiskSubmitRequest
from services.risk_service import RISK_QUESTIONS, calculate_risk_level
import httpx

risk_router = APIRouter(prefix="/risk", tags=["风险测评"])

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

@risk_router.get("/questions")
def get_questions():
    return RISK_QUESTIONS

@risk_router.get("/status")
async def get_risk_status(user_id: int = Depends(get_user_id_from_token), db: Session = Depends(get_db)):
    """获取风险评测状态"""
    account = db.query(Account).filter(Account.user_id == user_id).first()
    risk = db.query(RiskQuestionnaire).filter(RiskQuestionnaire.user_id == user_id).first()

    if not risk:
        return {
            "has_risk_assessment": False,
            "risk_level": None,
            "expire_date": None,
        }

    is_expired = risk.expire_date < date.today() if risk.expire_date else True

    return {
        "has_risk_assessment": not is_expired,
        "risk_level": risk.risk_level,
        "expire_date": risk.expire_date.isoformat() if risk.expire_date else None,
        "is_expired": is_expired,
    }

@risk_router.post("/submit")
async def submit_risk_questionnaire(
    answers: list,
    user_id: int = Depends(get_user_id_from_token),
    db: Session = Depends(get_db)
):
    total_score = sum(a.get("score", 0) for a in answers)
    risk_level = calculate_risk_level(total_score)
    expire_date = date.today() + timedelta(days=365)

    questionnaire = RiskQuestionnaire(
        user_id=user_id,
        answers=str(answers),
        score=total_score,
        risk_level=risk_level,
        expire_date=expire_date
    )
    db.add(questionnaire)

    account = db.query(Account).filter(Account.user_id == user_id).first()
    if account:
        account.risk_level = risk_level
        account.risk_expire_date = expire_date
        account.risk_status = "valid"

    db.commit()

    return {
        "message": "风险测评完成",
        "risk_level": risk_level,
        "expire_date": expire_date
    }