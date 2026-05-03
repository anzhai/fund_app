import re
from datetime import date, timedelta
from typing import Tuple

def validate_id_card(id_card: str) -> Tuple[bool, str]:
    """验证身份证号"""
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
    """验证身份证有效期"""
    if expire_date < date.today():
        return False, "身份证已过期"
    
    # Check if expiring soon (within 3 months)
    three_months_later = date.today() + timedelta(days=90)
    if expire_date <= three_months_later:
        return True, "身份证即将过期，建议更新"
    
    return True, "ok"

def calculate_id_card_validity(age: int) -> Tuple[int, str]:
    """根据年龄计算身份证有效期"""
    if age < 16:
        return 5, "5年"
    elif age < 26:
        return 10, "10年"
    elif age < 46:
        return 20, "20年"
    else:
        return 999, "长期"  # 999 represents long-term

def validate_trade_password(password: str, id_card: str, phone: str) -> Tuple[bool, str]:
    """验证交易密码强度"""
    if not password or len(password) != 6:
        return False, "交易密码必须为6位数字"

    if not password.isdigit():
        return False, "交易密码只能包含数字"

    # Check for arithmetic sequence (等差数列)
    digits = [int(d) for d in password]
    is_arithmetic = all(digits[i+1] - digits[i] == digits[1] - digits[0] for i in range(len(digits)-1))
    if is_arithmetic:
        return False, "交易密码不能为等差数列"

    # Check for palindrome (回文)
    if password == password[::-1]:
        return False, "交易密码不能为回文数"

    # Check for all same digits
    if len(set(password)) == 1:
        return False, "交易密码不能为重复数字"

    # Check against ID card last 6 digits
    if id_card and len(id_card) >= 6:
        id_last_6 = id_card[-6:]
        if password == id_last_6:
            return False, "交易密码不能为证件号后6位"

    # Check against phone last 6 digits
    if phone and len(phone) >= 6:
        phone_last_6 = phone[-6:]
        if password == phone_last_6:
            return False, "交易密码不能为手机号后6位"

    return True, "ok"

def validate_phone(phone: str) -> Tuple[bool, str]:
    """验证手机号"""
    if not re.match(r'^1[3-9]\d{9}$', phone):
        return False, "手机号格式不正确"
    return True, "ok"

def validate_bank_card(card_number: str) -> Tuple[bool, str]:
    """验证银行卡号（Luhn算法）"""
    if not card_number or not card_number.isdigit():
        return False, "银行卡号格式不正确"
    
    if len(card_number) < 13 or len(card_number) > 19:
        return False, "银行卡号长度不正确"
    
    # Luhn algorithm check
    def luhn_check(card_num: str) -> bool:
        digits = [int(d) for d in card_num]
        checksum = 0
        for i, digit in enumerate(reversed(digits)):
            if i % 2 == 1:
                digit *= 2
                if digit > 9:
                    digit -= 9
            checksum += digit
        return checksum % 10 == 0
    
    if not luhn_check(card_number):
        return False, "银行卡号校验失败"
    
    return True, "ok"

def validate_sms_code(code: str) -> Tuple[bool, str]:
    """验证短信验证码"""
    if not code or len(code) != 6 or not code.isdigit():
        return False, "验证码格式不正确"
    return True, "ok"
