# 数据库设计文档 - 基金理财应用

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 1. 数据库概览

| 属性 | 配置 |
|------|------|
| 数据库类型 | MySQL 8.0 |
| 字符集 | utf8mb4 |
| 排序规则 | utf8mb4_unicode_ci |
| 存储引擎 | InnoDB |

---

## 2. 表结构设计

### 2.1 users (用户表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 用户ID |
| phone | VARCHAR(11) | UNIQUE | 注册手机号 |
| id_card | VARCHAR(18) | UNIQUE | 身份证号(15位/18位) |
| password_hash | VARCHAR(255) | NOT NULL | 密码哈希(bcrypt) |
| salt | VARCHAR(32) | NOT NULL | 加密盐 |
| user_type | VARCHAR(20) | DEFAULT 'direct_sales' | direct_sales(直销)/agency(代销) |
| risk_level | VARCHAR(10) | NULL | 风险等级(R1-R5) |
| risk_expire_date | DATETIME | NULL | 风评过期时间 |
| is_verified | BOOLEAN | DEFAULT FALSE | 是否已开户 |
| is_active | BOOLEAN | DEFAULT TRUE | 账户是否激活 |
| last_login_device | VARCHAR(100) | NULL | 最后登录设备 |
| last_login_ip | VARCHAR(45) | NULL | 最后登录IP |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:**
- UNIQUE: phone, id_card
- INDEX: user_type, is_verified

---

### 2.2 accounts (账户表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 账户ID |
| user_id | INT | UNIQUE, NOT NULL, FK→users.id | 用户ID |
| id_card | VARCHAR(18) | NOT NULL | 证件号码 |
| id_card_type | VARCHAR(10) | DEFAULT 'id_card' | id_card/id_card_15/hamr/foreign |
| real_name | VARCHAR(50) | NOT NULL | 真实姓名 |
| id_card_expire | DATE | NOT NULL | 证件有效期 |
| risk_level | VARCHAR(10) | NULL | 风险等级 |
| risk_expire_date | DATE | NULL | 风评过期日期 |
| risk_status | VARCHAR(20) | DEFAULT 'not_done' | not_done/valid/expired |
| account_status | VARCHAR(20) | DEFAULT 'pending' | pending/active/frozen/closed |
| verification_status | VARCHAR(20) | DEFAULT 'pending' | pending/approved/rejected |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** INDEX idx_user_id (user_id)

---

### 2.3 bank_cards (银行卡表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 银行卡ID |
| user_id | INT | NOT NULL, FK→users.id | 用户ID |
| bank_name | VARCHAR(50) | NOT NULL | 银行名称 |
| bank_code | VARCHAR(20) | NOT NULL | 银行代码 |
| card_number | VARCHAR(30) | NOT NULL | 银行卡号(脱敏存储) |
| card_type | VARCHAR(20) | DEFAULT '储蓄卡' | 储蓄卡/信用卡 |
| is_default | BOOLEAN | DEFAULT FALSE | 是否默认卡 |
| is_pension | BOOLEAN | DEFAULT FALSE | 是否养老金账户 |
| status | VARCHAR(20) | DEFAULT 'active' | active/inactive/bound |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** INDEX idx_user_id (user_id)

---

### 2.4 risk_questionnaires (风险问卷表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 问卷ID |
| user_id | INT | UNIQUE, NOT NULL, FK→users.id | 用户ID |
| answers | TEXT | NULL | 答案JSON |
| score | INT | DEFAULT 0 | 得分 |
| risk_level | VARCHAR(10) | NULL | 风险等级 |
| expire_date | DATE | NULL | 过期日期 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**索引:** INDEX idx_user_id (user_id)

**风险等级映射:**

| 得分范围 | 风险等级 | 类型 |
|---------|---------|------|
| 0-20 | R1 | 安全型 |
| 21-40 | R2 | 保守型 |
| 41-60 | R3 | 稳健型 |
| 61-80 | R4 | 积极型 |
| 81-100 | R5 | 进取型 |

---

### 2.5 wallets (钱包表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 钱包ID |
| user_id | INT | UNIQUE, NOT NULL, FK→users.id | 用户ID |
| balance | DECIMAL(15,2) | DEFAULT 0.00 | 可用余额 |
| frozen_balance | DECIMAL(15,2) | DEFAULT 0.00 | 冻结余额 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** INDEX idx_user_id (user_id)

---

### 2.6 wallet_transactions (钱包流水表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 流水ID |
| user_id | INT | NOT NULL, FK→users.id | 用户ID |
| wallet_id | INT | NOT NULL, FK→wallets.id | 钱包ID |
| amount | DECIMAL(15,2) | NOT NULL | 金额(正数入账负数出账) |
| transaction_type | VARCHAR(20) | NOT NULL | recharge/withdraw/invest/redeem/bonus |
| status | VARCHAR(20) | DEFAULT 'completed' | pending/completed/failed |
| remark | VARCHAR(200) | NULL | 备注 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**索引:** INDEX idx_user_id (user_id), INDEX idx_wallet_id (wallet_id), INDEX idx_created_at (created_at)

---

### 2.7 funds (基金表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 基金ID |
| fund_code | VARCHAR(10) | UNIQUE, NOT NULL | 基金代码 |
| fund_name | VARCHAR(100) | NOT NULL | 基金名称 |
| fund_type | VARCHAR(20) | NOT NULL | money_market/stock/bond/hybrid/fof/qdii/commodity |
| risk_level | VARCHAR(10) | NOT NULL | 基金风险等级 |
| nav | DECIMAL(10,4) | NOT NULL | 单位净值 |
| acc_nav | DECIMAL(10,4) | NOT NULL | 累计净值 |
| min_purchase | DECIMAL(10,2) | DEFAULT 100.00 | 最小购买金额 |
| min_switch | DECIMAL(10,2) | DEFAULT 100.00 | 最小转换金额 |
| purchase_fee | DECIMAL(5,4) | DEFAULT 0.015 | 申购费率 |
| redeem_fee | DECIMAL(5,4) | DEFAULT 0.005 | 赎回费率 |
| manager_name | VARCHAR(50) | NULL | 基金经理 |
| company_name | VARCHAR(100) | NULL | 基金公司 |
| description | TEXT | NULL | 基金描述 |
| status | VARCHAR(20) | DEFAULT 'open' | open/closed/suspended |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** UNIQUE fund_code, INDEX idx_fund_type, INDEX idx_risk_level, INDEX idx_status

**基金类型映射:**

| fund_type | 说明 |
|-----------|------|
| money_market | 货币基金 |
| stock | 股票基金 |
| bond | 债券基金 |
| hybrid | 混合基金 |
| fof | FOF基金 |
| qdii | QDII基金 |
| commodity | 商品基金 |

---

### 2.8 fund_nav_history (净值历史表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 记录ID |
| fund_code | VARCHAR(10) | NOT NULL, FK→funds.fund_code | 基金代码 |
| nav_date | DATETIME | NOT NULL | 净值日期 |
| nav | DECIMAL(10,4) | NOT NULL | 单位净值 |
| acc_nav | DECIMAL(10,4) | NOT NULL | 累计净值 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**索引:** INDEX idx_fund_code (fund_code), INDEX idx_nav_date (nav_date), INDEX idx_fund_nav (fund_code, nav_date)

---

### 2.9 fund_profiles (基金持仓明细表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 记录ID |
| fund_code | VARCHAR(10) | NOT NULL, FK→funds.fund_code | 基金代码 |
| holding_stock_code | VARCHAR(10) | NULL | 持仓股票代码 |
| holding_stock_name | VARCHAR(100) | NULL | 持仓股票名称 |
| holding_ratio | DECIMAL(5,4) | NULL | 持仓占比 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**索引:** INDEX idx_fund_code (fund_code)

---

### 2.10 trade_orders (交易订单表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 订单ID |
| user_id | INT | NOT NULL, FK→users.id | 用户ID |
| fund_code | VARCHAR(10) | NOT NULL, FK→funds.fund_code | 基金代码 |
| fund_name | VARCHAR(100) | NOT NULL | 基金名称 |
| trade_type | VARCHAR(20) | NOT NULL | subscribe/purchase/redeem/convert/fixed/cancel |
| amount | DECIMAL(15,2) | NOT NULL | 交易金额 |
| shares | DECIMAL(15,4) | NULL | 交易份额 |
| nav | DECIMAL(10,4) | NULL | 确认净值 |
| fee | DECIMAL(10,2) | DEFAULT 0.00 | 手续费 |
| status | VARCHAR(20) | DEFAULT 'pending' | pending/completed/cancelled/failed |
| pay_method | VARCHAR(20) | NOT NULL | wallet/card/one_step |
| target_fund_code | VARCHAR(10) | NULL | 目标基金代码(转换用) |
| remark | VARCHAR(200) | NULL | 备注 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| confirmed_at | DATETIME | NULL | 确认时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** INDEX idx_user_id (user_id), INDEX idx_fund_code (fund_code), INDEX idx_trade_type (trade_type), INDEX idx_status, INDEX idx_created_at (created_at)

**交易类型映射:**

| trade_type | 说明 |
|------------|------|
| subscribe | 认购(新基金) |
| purchase | 申购 |
| redeem | 赎回 |
| convert | 转换 |
| fixed | 定投 |
| cancel | 撤单 |

**支付方式映射:**

| pay_method | 说明 |
|------------|------|
| wallet | 瑞钱包支付 |
| card | 银行卡支付 |
| one_step | 一步汇 |

---

### 2.11 portfolios (投资组合表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 组合ID |
| user_id | INT | NOT NULL, FK→users.id | 用户ID |
| portfolio_name | VARCHAR(100) | NOT NULL | 组合名称 |
| description | VARCHAR(500) | NULL | 组合描述 |
| status | VARCHAR(20) | DEFAULT 'active' | active/inactive |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** INDEX idx_user_id (user_id)

---

### 2.12 portfolio_positions (组合持仓表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 持仓ID |
| portfolio_id | INT | NOT NULL, FK→portfolios.id | 组合ID |
| fund_code | VARCHAR(10) | NOT NULL | 基金代码 |
| fund_name | VARCHAR(100) | NOT NULL | 基金名称 |
| target_ratio | DECIMAL(5,4) | NOT NULL | 目标占比 |
| current_amount | DECIMAL(15,2) | DEFAULT 0.00 | 当前金额 |
| current_shares | DECIMAL(15,4) | DEFAULT 0.00 | 当前份额 |
| nav | DECIMAL(10,4) | DEFAULT 1.0000 | 确认净值 |
| status | VARCHAR(20) | DEFAULT 'active' | active/sold |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** INDEX idx_portfolio_id (portfolio_id), INDEX idx_fund_code (fund_code)

---

### 2.13 fixed_investments (定投计划表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 计划ID |
| user_id | INT | NOT NULL, FK→users.id | 用户ID |
| fund_code | VARCHAR(10) | NOT NULL, FK→funds.fund_code | 基金代码 |
| fund_name | VARCHAR(100) | NOT NULL | 基金名称 |
| amount | DECIMAL(15,2) | NOT NULL | 每次定投金额 |
| invest_day | INT | NOT NULL | 每月定投日期(1-28) |
| status | VARCHAR(20) | DEFAULT 'active' | active/paused/stopped |
| start_date | DATE | NOT NULL | 起始日期 |
| end_date | DATE | NULL | 结束日期 |
| last_invest_date | DATE | NULL | 上次定投日期 |
| next_invest_date | DATE | NULL | 下次定投日期 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:** INDEX idx_user_id (user_id), INDEX idx_status, INDEX idx_next_invest_date (next_invest_date)

---

### 2.14 trace_records (留痕记录表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | 记录ID |
| user_id | INT | NOT NULL, FK→users.id | 用户ID |
| trace_type | VARCHAR(50) | NOT NULL | login/account/trade/risk_assesment |
| trace_content | TEXT | NULL | 留痕内容JSON |
| client_ip | VARCHAR(45) | NULL | 客户端IP |
| device_info | VARCHAR(200) | NULL | 设备信息 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**索引:** INDEX idx_user_id (user_id), INDEX idx_trace_type (trace_type), INDEX idx_created_at (created_at)

---

## 3. 关系约束

### 3.1 ER图

```
users (1) ────── (1) accounts
   │
   │ (1:n)
   │
   ├──── (1:1) wallets
   │           │
   │           │ (1:n)
   │           └─ wallet_transactions
   │
   ├──── (1:n) bank_cards
   │
   ├──── (1:1) risk_questionnaires
   │
   ├──── (1:n) trade_orders ────── (n:1) funds
   │
   └──── (1:n) portfolios
               │
               │ (1:n)
               └─ portfolio_positions ────── (n:1) funds

funds (1) ────── (1:n) fund_nav_history
       │
       └──── (1:n) fund_profiles
```

---

## 4. 性能优化

### 4.1 分表策略

| 表名 | 分表策略 |
|------|---------|
| trade_orders | 按月分表 (trade_orders_YYYYMM) |
| wallet_transactions | 按月分表 (wallet_transactions_YYYYMM) |
| trace_records | 按月分表 (trace_records_YYYYMM) |

### 4.2 缓存策略

| 数据 | 缓存时间 | 淘汰策略 |
|------|---------|---------|
| 用户信息 | 15分钟 | LRU |
| 风险等级 | 1小时 | LRU |
| 基金信息 | 5分钟 | LRU |
| 基金净值 | 1分钟 | LRU |

---

## 5. 数据迁移

### 5.1 迁移脚本命名规范

```
V{version}__{description}.sql
```

示例:
- V1.0.0__initial_schema.sql
- V1.1.0__add_pension_card.sql

### 5.2 迁移执行顺序

1. 备份数据
2. 执行迁移脚本
3. 验证数据完整性
4. 回滚（如需要）
