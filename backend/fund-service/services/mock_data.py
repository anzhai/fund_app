MOCK_FUNDS = [
    # 货币基金 (R1 - 低风险)
    {
        "fund_code": "000001",
        "fund_name": "华夏现金宝货币A",
        "fund_type": "money_market",
        "risk_level": "R1",
        "nav": 1.0000,
        "acc_nav": 1.2580,
        "min_purchase": 100.00,
        "purchase_fee": 0.0000,
        "redeem_fee": 0.0000,
        "manager_name": "张明",
        "company_name": "华夏基金",
        "description": "货币市场基金，主要投资短期银行存款、央行票据等低风险品种，流动性好"
    },
    {
        "fund_code": "000002",
        "fund_name": "易方达天天理财货币",
        "fund_type": "money_market",
        "risk_level": "R1",
        "nav": 1.0000,
        "acc_nav": 1.3120,
        "min_purchase": 100.00,
        "purchase_fee": 0.0000,
        "redeem_fee": 0.0000,
        "manager_name": "李华",
        "company_name": "易方达基金",
        "description": "低风险货币基金，适合现金管理"
    },
    
    # 债券基金 (R2 - 中低风险)
    {
        "fund_code": "000003",
        "fund_name": "嘉实超短债债券",
        "fund_type": "bond",
        "risk_level": "R2",
        "nav": 1.0520,
        "acc_nav": 1.4680,
        "min_purchase": 500.00,
        "purchase_fee": 0.0080,
        "redeem_fee": 0.0010,
        "manager_name": "王芳",
        "company_name": "嘉实基金",
        "description": "短债基金，风险较低，收益稳定"
    },
    {
        "fund_code": "000004",
        "fund_name": "南方稳健双利债券",
        "fund_type": "bond",
        "risk_level": "R2",
        "nav": 1.1250,
        "acc_nav": 1.5890,
        "min_purchase": 500.00,
        "purchase_fee": 0.0080,
        "redeem_fee": 0.0020,
        "manager_name": "赵强",
        "company_name": "南方基金",
        "description": "纯债基金，不投资股票，风险可控"
    },
    
    # 混合基金 (R3 - 中风险)
    {
        "fund_code": "000005",
        "fund_name": "易方达安心回报混合",
        "fund_type": "hybrid",
        "risk_level": "R3",
        "nav": 1.8500,
        "acc_nav": 2.3200,
        "min_purchase": 500.00,
        "purchase_fee": 0.0120,
        "redeem_fee": 0.0030,
        "manager_name": "陈伟",
        "company_name": "易方达基金",
        "description": "偏债混合型基金，股债平衡配置，追求稳健收益"
    },
    {
        "fund_code": "000006",
        "fund_name": "华夏成长优选混合",
        "fund_type": "hybrid",
        "risk_level": "R3",
        "nav": 2.1200,
        "acc_nav": 2.8900,
        "min_purchase": 500.00,
        "purchase_fee": 0.0150,
        "redeem_fee": 0.0050,
        "manager_name": "刘洋",
        "company_name": "华夏基金",
        "description": "平衡型混合基金，灵活配置股票和债券"
    },
    
    # FOF基金 (R4 - 中高风险)
    {
        "fund_code": "000007",
        "fund_name": "南方优选配置FOF",
        "fund_type": "fof",
        "risk_level": "R4",
        "nav": 1.2800,
        "acc_nav": 1.5600,
        "min_purchase": 1000.00,
        "purchase_fee": 0.0100,
        "redeem_fee": 0.0025,
        "manager_name": "孙丽",
        "company_name": "南方基金",
        "description": "基金中基金，通过优选基金组合实现资产配置"
    },
    {
        "fund_code": "000008",
        "fund_name": "嘉实多元配置FOF",
        "fund_type": "fof",
        "risk_level": "R4",
        "nav": 1.3500,
        "acc_nav": 1.6800,
        "min_purchase": 1000.00,
        "purchase_fee": 0.0100,
        "redeem_fee": 0.0025,
        "manager_name": "周杰",
        "company_name": "嘉实基金",
        "description": "多元化FOF基金，分散投资风险"
    },
    
    # 股票基金 (R5 - 高风险)
    {
        "fund_code": "000009",
        "fund_name": "易方达消费行业股票",
        "fund_type": "stock",
        "risk_level": "R5",
        "nav": 3.2500,
        "acc_nav": 4.1200,
        "min_purchase": 1000.00,
        "purchase_fee": 0.0150,
        "redeem_fee": 0.0050,
        "manager_name": "吴涛",
        "company_name": "易方达基金",
        "description": "股票型基金，重点投资消费行业优质企业"
    },
    {
        "fund_code": "000010",
        "fund_name": "华夏科技创新股票",
        "fund_type": "stock",
        "risk_level": "R5",
        "nav": 2.8900,
        "acc_nav": 3.5600,
        "min_purchase": 1000.00,
        "purchase_fee": 0.0150,
        "redeem_fee": 0.0050,
        "manager_name": "郑敏",
        "company_name": "华夏基金",
        "description": "科技主题股票基金，投资科技创新企业"
    },
    {
        "fund_code": "000011",
        "fund_name": "嘉实新能源股票",
        "fund_type": "stock",
        "risk_level": "R5",
        "nav": 2.4500,
        "acc_nav": 2.9800,
        "min_purchase": 1000.00,
        "purchase_fee": 0.0150,
        "redeem_fee": 0.0050,
        "manager_name": "钱峰",
        "company_name": "嘉实基金",
        "description": "新能源主题股票基金，把握绿色能源投资机会"
    },
    {
        "fund_code": "000012",
        "fund_name": "南方医药健康股票",
        "fund_type": "stock",
        "risk_level": "R5",
        "nav": 3.1200,
        "acc_nav": 3.8900,
        "min_purchase": 1000.00,
        "purchase_fee": 0.0150,
        "redeem_fee": 0.0050,
        "manager_name": "冯雪",
        "company_name": "南方基金",
        "description": "医药健康主题股票基金，聚焦医疗健康产业"
    },
]
