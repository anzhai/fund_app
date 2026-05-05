from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime

class IdCardOcrRequest(BaseModel):
    image_type: str = Field(..., description="图片类型: front(身份证正面), back(身份证反面)")
    image_data: str = Field(..., description="Base64编码的图片数据")

class IdCardOcrResponse(BaseModel):
    real_name: Optional[str] = Field(None, description="识别到的真实姓名")
    id_card: Optional[str] = Field(None, description="识别到的身份证号")
    gender: Optional[str] = Field(None, description="性别")
    nation: Optional[str] = Field(None, description="民族")
    birth_date: Optional[str] = Field(None, description="出生日期")
    address: Optional[str] = Field(None, description="地址")
    id_card_expire: Optional[str] = Field(None, description="身份证有效期")
    valid_date: Optional[str] = Field(None, description="有效期限")
    issued_by: Optional[str] = Field(None, description="签发机关")

class BankCardOcrRequest(BaseModel):
    image_data: str = Field(..., description="Base64编码的图片数据")

class BankCardOcrResponse(BaseModel):
    bank_name: Optional[str] = Field(None, description="银行名称")
    bank_code: Optional[str] = Field(None, description="银行代码")
    card_number: Optional[str] = Field(None, description="银行卡号")
    card_type: Optional[str] = Field(None, description="卡类型")

class AccountCreate(BaseModel):
    id_card: str = Field(..., description="身份证号")
    real_name: str = Field(..., description="真实姓名")
    id_card_expire: date = Field(..., description="身份证有效期")
    trade_password: str = Field(..., min_length=6, max_length=6, description="交易密码(6位数字)")

class BankCardAdd(BaseModel):
    bank_name: str = Field(..., description="银行名称")
    bank_code: str = Field(..., description="银行代码")
    card_number: str = Field(..., description="银行卡号")
    card_type: str = Field("储蓄卡", description="卡片类型")
    is_default: bool = Field(False, description="是否默认卡")

class RiskSubmitRequest(BaseModel):
    answers: list = Field(..., description="风险测评答案列表")

class AccountResponse(BaseModel):
    id: int
    user_id: int
    id_card: str
    id_card_type: str
    real_name: str
    id_card_expire: date
    risk_level: Optional[str]
    risk_expire_date: Optional[date]
    risk_status: str
    account_status: str
    verification_status: str
    created_at: datetime

    class Config:
        from_attributes = True

class BankCardResponse(BaseModel):
    id: int
    user_id: int
    bank_name: str
    bank_code: str
    card_number: str
    card_type: str
    is_default: bool
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class PasswordResetRequest(BaseModel):
    phone: str = Field(..., description="手机号")
    sms_code: str = Field(..., description="短信验证码")
    new_password: str = Field(..., min_length=6, description="新密码")
    confirm_password: str = Field(..., description="确认密码")

class TradePasswordResetRequest(BaseModel):
    id_card: str = Field(..., description="身份证号")
    phone: str = Field(..., description="预留手机号")
    sms_code: str = Field(..., description="短信验证码")
    new_password: str = Field(..., min_length=6, max_length=6, description="新交易密码")
    confirm_password: str = Field(..., description="确认密码")

class BankCardVerifyRequest(BaseModel):
    bank_code: str = Field(..., description="银行代码")
    card_number: str = Field(..., description="银行卡号")
    phone: str = Field(..., description="预留手机号")
    sms_code: str = Field(..., description="短信验证码")
