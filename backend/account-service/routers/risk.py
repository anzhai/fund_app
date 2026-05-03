from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import date, timedelta
from database import get_db
from models.account import RiskQuestionnaire, Account
from schemas.account import RiskSubmitRequest
from services.risk_service import RISK_QUESTIONS, calculate_risk_level

risk_router = APIRouter(prefix="/risk", tags=["风险测评"])

@risk_router.get("/questions")
def get_questions():
    return RISK_QUESTIONS

@risk_router.post("/submit")
def submit_risk_questionnaire(
    answers: list,
    user_id: int,
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