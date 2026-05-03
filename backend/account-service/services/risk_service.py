RISK_QUESTIONS = [
    {
        "id": 1,
        "question": "您的年龄范围是？",
        "options": [
            {"text": "18-30岁", "score": 10},
            {"text": "31-50岁", "score": 20},
            {"text": "51-65岁", "score": 30},
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
]

def calculate_risk_level(total_score: int) -> str:
    if total_score <= 25:
        return "C1"
    elif total_score <= 50:
        return "C2"
    elif total_score <= 75:
        return "C3"
    elif total_score <= 100:
        return "C4"
    else:
        return "C5"