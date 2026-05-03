RISK_QUESTIONS = [
    {
        "id": 1,
        "question": "您的年龄范围是？",
        "options": [
            {"text": "18-30岁", "score": 10},
            {"text": "31-50岁", "score": 20},
            {"text": "51-65岁", "score": 30},
            {"text": "65岁以上", "score": 40},
        ]
    },
    {
        "id": 2,
        "question": "您的投资经验年限？",
        "options": [
            {"text": "无经验", "score": 5},
            {"text": "1-3年", "score": 15},
            {"text": "3-5年", "score": 25},
            {"text": "5年以上", "score": 35},
        ]
    },
    {
        "id": 3,
        "question": "您能承受的最大损失？",
        "options": [
            {"text": "本金无损", "score": 5},
            {"text": "10%以内", "score": 15},
            {"text": "10%-30%", "score": 25},
            {"text": "30%以上", "score": 40},
        ]
    },
    {
        "id": 4,
        "question": "您的投资目的是？",
        "options": [
            {"text": "资产保值", "score": 5},
            {"text": "稳定收益", "score": 15},
            {"text": "资产增值", "score": 25},
            {"text": "高收益追求", "score": 40},
        ]
    },
    {
        "id": 5,
        "question": "市场下跌时您会？",
        "options": [
            {"text": "立即赎回", "score": 5},
            {"text": "观望等待", "score": 15},
            {"text": "适当加仓", "score": 25},
            {"text": "大额加仓", "score": 40},
        ]
    },
    {
        "id": 6,
        "question": "您的家庭年收入范围？",
        "options": [
            {"text": "10万以下", "score": 5},
            {"text": "10-30万", "score": 15},
            {"text": "30-50万", "score": 25},
            {"text": "50万以上", "score": 35},
        ]
    },
    {
        "id": 7,
        "question": "您可投资资金占家庭总资产比例？",
        "options": [
            {"text": "10%以下", "score": 5},
            {"text": "10%-30%", "score": 15},
            {"text": "30%-50%", "score": 25},
            {"text": "50%以上", "score": 35},
        ]
    },
]

def calculate_risk_level(total_score: int) -> str:
    """根据总分计算风险等级"""
    if total_score <= 35:
        return "C1"  # 保守型
    elif total_score <= 70:
        return "C2"  # 稳健型
    elif total_score <= 105:
        return "C3"  # 平衡型
    elif total_score <= 140:
        return "C4"  # 积极型
    else:
        return "C5"  # 激进型

def get_risk_level_name(level: str) -> str:
    """获取风险等级名称"""
    names = {
        "C1": "保守型",
        "C2": "稳健型",
        "C3": "平衡型",
        "C4": "积极型",
        "C5": "激进型"
    }
    return names.get(level, "未知")

def check_risk_match(user_risk_level: str, product_risk_level: str) -> tuple[bool, str]:
    """检查用户风险等级与产品风险等级是否匹配"""
    risk_levels = ["C1", "C2", "C3", "C4", "C5"]
    
    if user_risk_level not in risk_levels or product_risk_level not in risk_levels:
        return False, "风险等级参数错误"
    
    user_index = risk_levels.index(user_risk_level)
    product_index = risk_levels.index(product_risk_level)
    
    if user_index >= product_index:
        return True, "风险匹配，可以购买"
    else:
        return False, f"您的风险等级({get_risk_level_name(user_risk_level)})低于产品风险等级({get_risk_level_name(product_risk_level)})，建议重新测评或选择低风险产品"
