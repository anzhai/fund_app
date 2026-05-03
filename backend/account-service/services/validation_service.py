import re
from datetime import date
from typing import Tuple

def validate_id_card(id_card: str) -> Tuple[bool, str]:
    if not id_card:
        return False, "身份证号不能为空"

    if len(id_card) not in [15, 18]:
        return False, "身份证号长度应为15位或18位"

    if len(id_card) == 18:
        if not re.match(r'^\d{17}[\dXx]$', id_card):
            return False, "18位身份证格式不正确"

        birth_year = int(id_card[6:10])
        birth_month = int(id_card[10:12])
        birth_day = int(id_card[12:14])

        try:
            birth_date = date(birth_year, birth_month, birth_day)
        except ValueError:
            return False, "身份证号中的出生日期无效"

        today = date.today()
        age = today.year - birth_year - ((today.month, today.day) < (birth_month, birth_day))
        if age < 18:
            return False, "必须年满18周岁才能开户"

    return True, "ok"

def validate_id_card_expire(expire_date: date) -> Tuple[bool, str]:
    if expire_date < date.today():
        return False, "身份证已过期"
    return True, "ok"

def validate_trade_password(password: str, id_card: str, phone: str) -> Tuple[bool, str]:
    if not password or len(password) < 6:
        return False, "交易密码至少6位"

    sequential = "0123456789" * 3
    reverse_sequential = "9876543210" * 3
    if password in sequential or password in reverse_sequential:
        return False, "交易密码不能为连续数字"

    if len(set(password)) == 1:
        return False, "交易密码不能为重复数字"

    if id_card and len(id_card) >= 6:
        id_last_6 = id_card[-6:]
        if password == id_last_6 or password in id_last_6 * 2:
            return False, "交易密码不能为证件号连续6位"

    return True, "ok"

def validate_phone(phone: str) -> Tuple[bool, str]:
    if not re.match(r'^1[3-9]\d{9}$', phone):
        return False, "手机号格式不正确"
    return True, "ok"