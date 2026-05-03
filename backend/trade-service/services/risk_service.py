from decimal import Decimal
from typing import Tuple

RISK_MATRIX = {
    "C1": "R1",
    "C2": "R2",
    "C3": "R3",
    "C4": "R4",
    "C5": "R5",
}

RISK_LEVEL_ORDER = ["R1", "R2", "R3", "R4", "R5"]

def check_risk_match(user_risk_level: str, fund_risk_level: str) -> Tuple[bool, str]:
    if not user_risk_level:
        return False, "用户未进行风险测评"

    max_allowed = RISK_MATRIX.get(user_risk_level)
    if not max_allowed:
        return False, "用户风险等级无效"

    user_level_index = RISK_LEVEL_ORDER.index(max_allowed)
    fund_level_index = RISK_LEVEL_ORDER.index(fund_risk_level)

    if fund_level_index <= user_level_index:
        return True, "风险匹配"
    else:
        return False, f"该基金风险等级为{fund_risk_level}，您的风险等级为{user_risk_level}，不匹配"

def check_amount_limit(amount: Decimal, single_limit: Decimal = Decimal("50000")) -> Tuple[bool, str]:
    if amount > single_limit:
        return False, f"单笔交易限额为{single_limit}元"
    return True, "ok"

def check_daily_limit(total_today: Decimal, amount: Decimal, daily_limit: Decimal = Decimal("200000")) -> Tuple[bool, str]:
    if total_today + amount > daily_limit:
        return False, f"当日交易限额为{daily_limit}元"
    return True, "ok"