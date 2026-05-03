from pydantic import BaseModel
from typing import Optional
from datetime import date

class AccountCreate(BaseModel):
    id_card: str
    real_name: str
    id_card_expire: date
    trade_password: str

class BankCardAdd(BaseModel):
    bank_name: str
    bank_code: str
    card_number: str
    is_default: bool = False

class RiskSubmitRequest(BaseModel):
    answers: list