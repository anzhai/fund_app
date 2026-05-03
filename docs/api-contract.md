# API接口定义文档 - 基金理财应用

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 1. 接口规范

### 1.1 基本规范

| 项目 | 规范 |
|------|------|
| 协议 | HTTPS |
| 数据格式 | JSON |
| 字符编码 | UTF-8 |
| API版本 | /api/v1/ |
| 认证方式 | Bearer Token (JWT) |

### 1.2 响应格式

```json
{
  "code": 0,
  "message": "success",
  "data": {}
}
```

| code | 说明 |
|------|------|
| 0 | 成功 |
| 400xxx | 参数错误 |
| 401xxx | 认证错误 |
| 403xxx | 权限错误 |
| 500xxx | 服务器错误 |

### 1.3 分页格式

```json
{
  "page": 1,
  "page_size": 20,
  "total": 100,
  "items": []
}
```

---

## 2. 认证模块 (auth-service:8001)

### 2.1 用户注册/登录

#### POST /api/v1/auth/register - 快速注册

**请求:**
```json
{
  "phone": "13800138000",
  "password": "Abc123!",
  "sms_code": "123456",
  "id_card": "110101199001011234"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": 1,
    "access_token": "eyJ...",
    "refresh_token": "eyJ..."
  }
}
```

---

#### POST /api/v1/auth/login - 用户登录

**请求:**
```json
{
  "login_type": "phone",  // phone/id_card/sms
  "phone": "13800138000",
  "password": "Abc123!",
  "id_card": "110101199001011234"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": 1,
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "is_verified": true,
    "risk_level": "R3"
  }
}
```

---

#### POST /api/v1/auth/sms_login - 短信验证码登录

**请求:**
```json
{
  "phone": "13800138000",
  "sms_code": "123456"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": 1,
    "access_token": "eyJ..."
  }
}
```

---

#### POST /api/v1/auth/sms_code - 发送短信验证码

**请求:**
```json
{
  "phone": "13800138000",
  "scene": "login"  // login/register/forget_password
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success"
}
```

---

#### POST /api/v1/auth/refresh_token - 刷新Token

**请求:**
```json
{
  "refresh_token": "eyJ..."
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "eyJ..."
  }
}
```

---

#### POST /api/v1/auth/reset_password - 重置密码

**请求:**
```json
{
  "phone": "13800138000",
  "sms_code": "123456",
  "new_password": "Abc123!"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success"
}
```

---

### 2.2 第三方登录

#### POST /api/v1/auth/third_party/login - 第三方登录

**请求:**
```json
{
  "platform": "wechat",  // wechat/apple/huawei
  "open_id": "oauth_open_id",
  "access_token": "platform_access_token"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": 1,
    "access_token": "eyJ...",
    "is_new_user": false
  }
}
```

---

### 2.3 生物识别

#### POST /api/v1/auth/biometric/login - 生物识别登录

**请求:**
```json
{
  "biometric_token": "biometric_challenge_response"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": 1,
    "access_token": "eyJ..."
  }
}
```

---

## 3. 账户模块 (account-service:8002)

### 3.1 开户

#### POST /api/v1/account/open - 开户

**请求:**
```json
{
  "id_card_type": "id_card",  // id_card/id_card_15/hamr/foreign
  "id_card": "110101199001011234",
  "real_name": "张三",
  "id_card_expire": "2030-01-01",
  "bank_card": {
    "bank_name": "中国银行",
    "bank_code": "BOC",
    "card_number": "6217000012345678",
    "card_type": "储蓄卡"
  },
  "password": "123456"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "account_id": 1,
    "verification_status": "approved"
  }
}
```

---

#### POST /api/v1/account/id_card/upload - 上传证件照片

**请求:** (multipart/form-data)
```
id_card_front: file
id_card_back: file
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "ocr_result": {
      "name": "张三",
      "id_card": "110101199001011234",
      "address": "北京市朝阳区...",
      "birthday": "1990-01-01",
      "gender": "男",
      "nation": "汉"
    }
  }
}
```

---

#### GET /api/v1/account/info - 账户信息

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": 1,
    "phone": "138****8000",
    "real_name": "张*",
    "id_card": "110***********1234",
    "id_card_expire": "2030-01-01",
    "is_verified": true,
    "account_status": "active",
    "risk_level": "R3",
    "risk_expire_date": "2027-05-03",
    "risk_status": "valid"
  }
}
```

---

### 3.2 银行卡

#### GET /api/v1/account/cards - 银行卡列表

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "id": 1,
      "bank_name": "中国银行",
      "bank_code": "BOC",
      "card_number": "****1234",
      "card_type": "储蓄卡",
      "is_default": true,
      "is_pension": false
    }
  ]
}
```

---

#### POST /api/v1/account/cards - 添加银行卡

**请求:**
```json
{
  "bank_name": "中国银行",
  "bank_code": "BOC",
  "card_number": "6217000012345678",
  "card_type": "储蓄卡"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "card_id": 1
  }
}
```

---

#### DELETE /api/v1/account/cards/{card_id} - 解绑银行卡

**响应:**
```json
{
  "code": 0,
  "message": "success"
}
```

---

### 3.3 风险评估

#### GET /api/v1/account/risk/questions - 获取风评问卷

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "questions": [
      {
        "id": 1,
        "question": "您的年龄是？",
        "options": [
          {"value": "A", "label": "18-30岁"},
          {"value": "B", "label": "31-50岁"},
          {"value": "C", "label": "51-65岁"}
        ]
      }
    ],
    "total_count": 20
  }
}
```

---

#### POST /api/v1/account/risk/submit - 提交风评

**请求:**
```json
{
  "answers": [
    {"question_id": 1, "answer": "A"},
    {"question_id": 2, "answer": "B"}
  ]
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "score": 65,
    "risk_level": "R4",
    "risk_type": "积极型",
    "expire_date": "2027-05-03"
  }
}
```

---

#### GET /api/v1/account/risk/history - 风评历史

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "history": [
      {
        "id": 1,
        "score": 65,
        "risk_level": "R4",
        "created_at": "2024-01-01 10:00:00"
      }
    ]
  }
}
```

---

### 3.4 安全设置

#### POST /api/v1/account/password/login - 修改登录密码

**请求:**
```json
{
  "old_password": "Abc123!",
  "new_password": "Xyz789!"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success"
}
```

---

#### POST /api/v1/account/password/trade - 修改交易密码

**请求:**
```json
{
  "old_password": "123456",
  "new_password": "654321"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success"
}
```

---

#### POST /api/v1/account/biometric/enable - 开启生物识别

**请求:**
```json
{
  "biometric_type": "fingerprint",  // fingerprint/face
  "biometric_token": "challenge_response"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success"
}
```

---

## 4. 基金模块 (fund-service:8003)

### 4.1 基金列表

#### GET /api/v1/funds - 基金列表

**Query参数:**
| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 基金类型筛选 |
| risk_level | string | 风险等级筛选 |
| keyword | string | 搜索关键字 |
| page | int | 页码 |
| page_size | int | 每页数量 |

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "page": 1,
    "page_size": 20,
    "total": 100,
    "items": [
      {
        "fund_code": "000001",
        "fund_name": "货币基金A",
        "fund_type": "money_market",
        "risk_level": "R1",
        "nav": 1.0000,
        "acc_nav": 1.0000,
        "day_growth": 0.12,
        "min_purchase": 100.00
      }
    ]
  }
}
```

---

#### GET /api/v1/funds/{fund_code} - 基金详情

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "fund_code": "000001",
    "fund_name": "货币基金A",
    "fund_type": "money_market",
    "risk_level": "R1",
    "nav": 1.0000,
    "acc_nav": 1.0000,
    "day_growth": 0.12,
    "min_purchase": 100.00,
    "purchase_fee": 0.0000,
    "redeem_fee": 0.0000,
    "manager_name": "张经理",
    "company_name": "华夏基金",
    "description": "货币市场基金...",
    "status": "open"
  }
}
```

---

#### GET /api/v1/funds/{fund_code}/nav_history - 净值历史

**Query参数:**
| 参数 | 类型 | 说明 |
|------|------|------|
| start_date | string | 开始日期 |
| end_date | string | 结束日期 |

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "history": [
      {"nav_date": "2026-05-02", "nav": 1.0000, "acc_nav": 1.0000},
      {"nav_date": "2026-05-01", "nav": 0.9999, "acc_nav": 0.9999}
    ]
  }
}
```

---

#### GET /api/v1/funds/{fund_code}/profiles - 基金持仓

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "holdings": [
      {
        "stock_code": "600000",
        "stock_name": "浦发银行",
        "holding_ratio": 0.0532
      }
    ]
  }
}
```

---

## 5. 交易模块 (trade-service:8005)

### 5.1 基金交易

#### POST /api/v1/trade/purchase - 申购

**请求:**
```json
{
  "fund_code": "000001",
  "amount": 1000.00,
  "pay_method": "wallet"  // wallet/card
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "order_id": 1,
    "fund_code": "000001",
    "fund_name": "货币基金A",
    "amount": 1000.00,
    "shares": 1000.0000,
    "nav": 1.0000,
    "fee": 0.00,
    "status": "pending"
  }
}
```

---

#### POST /api/v1/trade/redeem - 赎回

**请求:**
```json
{
  "fund_code": "000001",
  "shares": 500.0000,
  "redeem_type": "fast"  // fast/normal
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "order_id": 2,
    "fund_code": "000001",
    "shares": 500.0000,
    "amount": 500.00,
    "fee": 0.50,
    "arrival_time": "2026-05-04",
    "status": "pending"
  }
}
```

---

#### POST /api/v1/trade/subscribe - 认购

**请求:**
```json
{
  "fund_code": "000001",
  "amount": 10000.00,
  "pay_method": "wallet"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "order_id": 3,
    "status": "pending"
  }
}
```

---

#### POST /api/v1/trade/convert - 基金转换

**请求:**
```json
{
  "source_fund_code": "000001",
  "target_fund_code": "000002",
  "amount": 500.00
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "order_id": 4,
    "status": "pending"
  }
}
```

---

#### POST /api/v1/trade/cancel/{order_id} - 撤单

**响应:**
```json
{
  "code": 0,
  "message": "success"
}
```

---

### 5.2 定投

#### GET /api/v1/trade/fixed - 定投列表

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1,
        "fund_code": "000001",
        "fund_name": "货币基金A",
        "amount": 500.00,
        "invest_day": 15,
        "status": "active",
        "next_invest_date": "2026-06-15"
      }
    ]
  }
}
```

---

#### POST /api/v1/trade/fixed - 新增定投

**请求:**
```json
{
  "fund_code": "000001",
  "amount": 500.00,
  "invest_day": 15
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "fixed_id": 1
  }
}
```

---

#### PUT /api/v1/trade/fixed/{fixed_id} - 修改定投

**请求:**
```json
{
  "amount": 1000.00,
  "invest_day": 20
}
```

---

#### DELETE /api/v1/trade/fixed/{fixed_id} - 终止定投

---

### 5.3 钱包

#### GET /api/v1/trade/wallet - 钱包信息

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "balance": 10000.00,
    "frozen_balance": 0.00,
    "可用余额": 10000.00
  }
}
```

---

#### POST /api/v1/trade/wallet/recharge - 充值

**请求:**
```json
{
  "amount": 1000.00,
  "pay_method": "one_step"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "transaction_id": 1
  }
}
```

---

#### POST /api/v1/trade/wallet/withdraw - 提现

**请求:**
```json
{
  "amount": 500.00,
  "card_id": 1
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "transaction_id": 2,
    "arrival_time": "2026-05-05"
  }
}
```

---

### 5.4 交易记录

#### GET /api/v1/trade/orders - 交易记录

**Query参数:**
| 参数 | 类型 | 说明 |
|------|------|------|
| trade_type | string | 交易类型 |
| status | string | 订单状态 |
| start_date | string | 开始日期 |
| end_date | string | 结束日期 |
| page | int | 页码 |

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "page": 1,
    "page_size": 20,
    "total": 50,
    "items": [
      {
        "order_id": 1,
        "fund_code": "000001",
        "fund_name": "货币基金A",
        "trade_type": "purchase",
        "amount": 1000.00,
        "shares": 1000.0000,
        "nav": 1.0000,
        "status": "completed",
        "created_at": "2026-05-02 10:00:00"
      }
    ]
  }
}
```

---

## 6. 组合模块 (portfolio-service:8004)

### 6.1 投资组合

#### GET /api/v1/portfolios - 组合列表

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1,
        "portfolio_name": "我的养老计划",
        "description": "长期稳健投资",
        "total_amount": 50000.00,
        "day_gain": 50.00,
        "day_gain_rate": 0.10,
        "status": "active"
      }
    ]
  }
}
```

---

#### POST /api/v1/portfolios - 创建组合

**请求:**
```json
{
  "portfolio_name": "我的养老计划",
  "description": "长期稳健投资"
}
```

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "portfolio_id": 1
  }
}
```

---

#### GET /api/v1/portfolios/{portfolio_id} - 组合详情

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 1,
    "portfolio_name": "我的养老计划",
    "total_amount": 50000.00,
    "day_gain": 50.00,
    "day_gain_rate": 0.10,
    "positions": [
      {
        "fund_code": "000001",
        "fund_name": "货币基金A",
        "target_ratio": 0.3,
        "current_amount": 15000.00,
        "current_ratio": 0.3,
        "gain": 15.00
      }
    ]
  }
}
```

---

#### POST /api/v1/portfolios/{portfolio_id}/rebalance - 组合调仓

**请求:**
```json
{
  "adjustments": [
    {"fund_code": "000001", "target_ratio": 0.4},
    {"fund_code": "000002", "target_ratio": 0.6}
  ]
}
```

---

## 7. 资产模块

### 7.1 资产总览

#### GET /api/v1/asset/overview - 资产总览

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "total_asset": 100000.00,
    "total_gain": 5000.00,
    "total_gain_rate": 5.26,
    "wallet_balance": 10000.00,
    "funds_value": 90000.00,
    "yesterday_gain": 50.00
  }
}
```

---

### 7.2 持仓

#### GET /api/v1/asset/positions - 持仓列表

**响应:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "fund_code": "000001",
        "fund_name": "货币基金A",
        "shares": 10000.0000,
        "nav": 1.0000,
        "current_value": 10000.00,
        "cost": 10000.00,
        "gain": 0.00,
        "gain_rate": 0.00
      }
    ]
  }
}
```

---

## 8. 错误码汇总

| 错误码 | 说明 |
|--------|------|
| 400001 | 参数校验失败 |
| 400002 | 短信验证码错误 |
| 400003 | 短信验证码过期 |
| 401001 | Token无效 |
| 401002 | Token过期 |
| 401003 | RefreshToken无效 |
| 403001 | 用户被禁用 |
| 403002 | 未开户 |
| 403003 | 风评未做 |
| 403004 | 风评已过期 |
| 403005 | 适当性不匹配 |
| 403006 | 风险等级不足 |
| 403007 | 投资期限不匹配 |
| 403008 | 证件已过期 |
| 403009 | 大额交易需双因素验证 |
| 404001 | 基金不存在 |
| 404002 | 订单不存在 |
| 404003 | 银行卡不存在 |
| 500001 | 服务器内部错误 |
| 500002 | 数据库错误 |
| 500003 | 第三方支付错误 |
