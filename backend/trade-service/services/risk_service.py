from decimal import Decimal
from typing import Tuple, Optional

RISK_MATRIX = {
    "C1": "R1",  # 保守型 -> 低风险
    "C2": "R2",  # 稳健型 -> 中低风险
    "C3": "R3",  # 平衡型 -> 中风险
    "C4": "R4",  # 积极型 -> 中高风险
    "C5": "R5",  # 激进型 -> 高风险
}

RISK_LEVEL_ORDER = ["R1", "R2", "R3", "R4", "R5"]

# Transaction limits
SINGLE_PURCHASE_LIMIT = Decimal("50000")  # 单笔购买限额5万
DAILY_PURCHASE_LIMIT = Decimal("200000")  # 单日购买限额20万
FAST_WITHDRAW_LIMIT = Decimal("10000")    # 快速取现限额1万
LARGE_AMOUNT_THRESHOLD = Decimal("200000") # 大额交易阈值20万

def check_risk_match(user_risk_level: str, fund_risk_level: str) -> Tuple[bool, str]:
    """检查用户风险等级与基金风险等级是否匹配"""
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

def check_amount_limit(amount: Decimal, single_limit: Decimal = SINGLE_PURCHASE_LIMIT) -> Tuple[bool, str]:
    """检查单笔交易限额"""
    if amount > single_limit:
        return False, f"单笔交易限额为{single_limit}元"
    return True, "ok"

def check_daily_limit(total_today: Decimal, amount: Decimal, daily_limit: Decimal = DAILY_PURCHASE_LIMIT) -> Tuple[bool, str]:
    """检查单日交易限额"""
    if total_today + amount > daily_limit:
        return False, f"当日交易限额为{daily_limit}元"
    return True, "ok"

def check_large_amount(amount: Decimal, threshold: Decimal = LARGE_AMOUNT_THRESHOLD) -> Tuple[bool, str]:
    """检查是否为大额交易，需要双因素验证"""
    if amount >= threshold:
        return False, f"交易金额≥{threshold}元，需要进行双因素验证"
    return True, "ok"

def check_fast_withdraw_limit(amount: Decimal, limit: Decimal = FAST_WITHDRAW_LIMIT) -> Tuple[bool, str]:
    """检查快速取现限额"""
    if amount > limit:
        return False, f"快速取现单笔限额为{limit}元"
    return True, "ok"

def check_account_status(
    account_opened: bool,
    risk_assessed: bool,
    risk_expired: bool,
    id_card_valid: bool,
    info_complete: bool
) -> Tuple[bool, str]:
    """检查账户状态是否允许交易"""
    if not account_opened:
        return False, "您还未开户，请先完成开户流程"
    
    if not info_complete:
        return False, "您的个人信息不完善，请完善信息后再交易"
    
    if not id_card_valid:
        return False, "您的身份证已过期，请更新证件后再交易"
    
    if not risk_assessed:
        return False, "您还未进行风险测评，请先完成风险测评"
    
    if risk_expired:
        return False, "您的风险测评已过期，请重新测评"
    
    return True, "账户状态正常"
