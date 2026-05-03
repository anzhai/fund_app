# 架构设计文档 - 基金理财应用

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 1. 系统架构

### 1.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                      Flutter App (用户端)                        │
│                    iOS / Android / Web                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Nginx Gateway                             │
│              (反向代理 + 负载均衡 + SSL终结)                       │
└────────┬────────┬────────┬────────┬──────────────────────────────┘
         │        │        │        │
         ▼        ▼        ▼        ▼
┌────────────┐ ┌────────┐ ┌────────┐ ┌─────────────┐ ┌──────────┐
│auth-service│ │account │ │ fund   │ │ portfolio  │ │ trade    │
│   8001     │ │ 8002   │ │ 8003   │ │   8004     │ │  8005    │
│            │ │        │ │        │ │            │ │          │
│• 注册/登录 │ │• 开户  │ │• 基金  │ │• 组合管理 │ │• 认购    │
│• JWT认证   │ │• 风险  │ │• 净值  │ │• 调仓     │ │• 申购    │
│• 第三方    │ │• 账户  │ │• 搜索  │ │• 监控     │ │• 赎回    │
│• Oauth     │ │• 银行卡│ │• 详情  │ │           │ │• 定投    │
└─────┬──────┘ └───┬────┘ └───┬────┘ └──────┬─────┘ └───┬──────┘
      │            │         │             │           │
      └────────────┴─────────┴─────────────┴───────────┘
                     │            │
                     ▼            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Shared Services                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │    MySQL     │  │    Redis     │  │      RabbitMQ         │   │
│  │   3306       │  │    6379     │  │  5672 / 15672        │   │
│  │              │  │              │  │                      │   │
│  │ • 用户数据   │  │ • 会话管理   │  │ • 异步消息队列       │   │
│  │ • 基金数据   │  │ • 缓存       │  │ • 交易异步处理        │   │
│  │ • 交易订单   │  │ • Token存储  │  │ • 通知推送            │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 技术栈

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| 前端 | Flutter 3.x | 跨平台移动端框架 |
| 网关 | Nginx | 反向代理/负载均衡 |
| 后端 | Python FastAPI | 异步API框架 |
| ORM | SQLAlchemy | 数据库ORM |
| 数据库 | MySQL 8.0 | 关系型数据库 |
| 缓存 | Redis 7 | 会话/缓存/消息队列 |
| 消息队列 | RabbitMQ | 异步任务/事件驱动 |
| 认证 | JWT | 无状态认证 |

---

## 2. 服务划分

### 2.1 服务矩阵

| 服务 | 端口 | 职责 | 数据库表 | 缓存 |
|------|------|------|---------|------|
| auth-service | 8001 | 用户认证、JWT签发、第三方登录 | users | JWT Token、Session |
| account-service | 8002 | 开户管理、风险评估、银行卡 | accounts、bank_cards、risk_questionnaires | 用户信息、风评结果 |
| fund-service | 8003 | 基金信息、净值查询、搜索 | funds、fund_nav_history、fund_profiles | 基金信息、净值 |
| portfolio-service | 8004 | 投资组合、持仓、调仓 | portfolios、portfolio_positions | 组合数据 |
| trade-service | 8005 | 交易订单、钱包、充值提现 | trade_orders、wallets、wallet_transactions | 订单状态 |

### 2.2 服务依赖关系

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                            │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Nginx Gateway                          │
└─────────────────────────────┬───────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ auth-service  │   │ fund-service  │   │trade-service  │
│               │   │               │   │               │
│ • 验证Token   │   │ • 基金列表   │   │ • 基金交易    │
│ • 登录注册   │   │ • 基金详情   │   │ • 钱包充值    │
└───────┬───────┘   └───────────────┘   └───────┬───────┘
        │                                         │
        ▼                                         ▼
┌───────────────┐                         ┌───────────────┐
│account-service│                         │portfolio-svc  │
│               │                         │               │
│ • 风评校验   │◄────────────────────────►│ • 持仓查询   │
│ • 开户校验   │   (持仓风险匹配)          │ • 组合调仓   │
└───────────────┘                         └───────────────┘
```

### 2.3 服务健康检查

| 服务 | 健康检查端点 | 状态检查 |
|------|------------|---------|
| auth-service | GET /health | DB + Redis |
| account-service | GET /health | DB |
| fund-service | GET /health | DB + 外部API |
| portfolio-service | GET /health | DB |
| trade-service | GET /health | DB + Redis |

---

## 3. 数据库设计

### 3.1 ER图

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   users     │       │  accounts   │       │ bank_cards  │
│─────────────│       │─────────────│       │─────────────│
│ id (PK)     │──┐    │ id (PK)     │       │ id (PK)     │
│ phone       │  │    │ user_id (FK)│◄──────│ user_id (FK)│
│ id_card     │  └───►│ id_card     │       │ bank_name   │
│ password    │       │ real_name   │       │ card_number │
│ user_type   │       │ risk_level  │       │ is_default  │
│ risk_level  │       └─────────────┘       └─────────────┘
└─────────────┘              │
       │                     │
       │              ┌─────────────┐
       │              │ risk_quest │
       │              │─────────────│
       │              │ user_id (FK)│◄──────┐
       │              │ answers     │       │
       │              │ score       │       │
       │              │ risk_level  │       │
       │              └─────────────┘       │
       │                                     │
       ▼                                     ▼
┌─────────────┐       ┌─────────────┐  ┌─────────────┐
│  wallets    │       │trade_orders │  │ portfolios │
│─────────────│      │─────────────│  │─────────────│
│ id (PK)     │      │ id (PK)     │  │ id (PK)     │
│ user_id (FK)│◄────►│ user_id (FK)│  │ user_id (FK)│
│ balance     │      │ fund_code   │  │ portfolio_  │
│ frozen_bal  │      │ trade_type  │  │   name      │
└─────────────┘      │ amount      │  └──────┬──────┘
                     │ status      │         │
                     └──────┬──────┘         ▼
                           │         ┌─────────────┐
                           │         │portfolio_   │
                           │         │positions    │
                           │         │─────────────│
                           │         │ portfolio_id│
                           │         │ fund_code   │
                           │         │ target_ratio│
                           │         │ current_    │
                           │         │   amount    │
                           │         └─────────────┘
                           │
                           ▼
                     ┌─────────────┐       ┌─────────────┐
                     │   funds    │       │ fund_nav_   │
                     │─────────────│       │  history    │
                     │ fund_code  │◄──────│─────────────│
                     │ fund_name  │       │ fund_code   │
                     │ fund_type  │       │ nav_date    │
                     │ nav        │       │ nav         │
                     │ risk_level │       └─────────────┘
                     └─────────────┘
```

### 3.2 表结构汇总

| 表名 | 主键 | 外键 | 说明 |
|------|------|------|------|
| users | id | - | 用户表 |
| accounts | id | user_id | 账户表 |
| bank_cards | id | user_id | 银行卡表 |
| risk_questionnaires | id | user_id | 风险问卷表 |
| wallets | id | user_id | 钱包表 |
| wallet_transactions | id | wallet_id | 钱包流水表 |
| trade_orders | id | user_id, fund_code | 交易订单表 |
| funds | id | - | 基金表 |
| fund_nav_history | id | fund_code | 净值历史表 |
| fund_profiles | id | fund_code | 基金持仓明细表 |
| portfolios | id | user_id | 投资组合表 |
| portfolio_positions | id | portfolio_id, fund_code | 组合持仓表 |

### 3.3 索引设计

| 表名 | 索引类型 | 字段 |
|------|---------|------|
| users | UNIQUE | phone, id_card |
| accounts | INDEX | user_id |
| bank_cards | INDEX | user_id |
| trade_orders | INDEX | user_id, fund_code, trade_type, created_at |
| fund_nav_history | INDEX | fund_code, nav_date |
| portfolios | INDEX | user_id |
| portfolio_positions | INDEX | portfolio_id |

---

## 4. API设计

### 4.1 网关路由

```
Nginx Port: 80

/auth-service/     → auth-service:8001
/account-service/  → account-service:8002
/fund-service/    → fund-service:8003
/portfolio-service/→ portfolio-service:8004
/trade-service/   → trade-service:8005
```

### 4.2 API版本

所有API使用 `/api/v1/` 前缀

### 4.3 认证流程

```
请求 → Nginx → Auth Service → 验证JWT → 下游服务

JWT Payload:
{
  "sub": user_id,
  "exp": expires_at,
  "type": "access" | "refresh"
}
```

---

## 5. 安全设计

### 5.1 认证机制

| 项目 | 配置 |
|------|------|
| Access Token | 15分钟过期 |
| Refresh Token | 7天过期 |
| 密码加密 | bcrypt + 随机盐 |
| JWT Secret | 环境变量配置 |

### 5.2 权限控制

| 用户类型 | 风险等级 | 可交易基金 |
|---------|---------|-----------|
| 直销已风评 | R1-R5 | 匹配等级 |
| 直销未风评 | 安全型 | 仅R1 |
| 代销用户 | 安全型 | 仅R1 |
| 专业投资者 | 进取型 | 全部 |

### 5.3 留痕要求

| 场景 | 前端留痕 | 后端留痕 |
|------|---------|---------|
| 登录 | usr_trace_record | tc_trequesttraceinfo |
| 开户 | - | tc_trequesttraceinfo |
| 交易 | - | tc_trequesttraceinfo |
| 风评 | - | tc_trequesttraceinfo |

---

## 6. 部署架构

### 6.1 Docker Compose拓扑

```
┌─────────────────────────────────────────────────────────┐
│                    docker-compose                      │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐  │
│  │                   MySQL                          │  │
│  │              mysql:8.0 :3306                     │  │
│  └─────────────────────────────────────────────────┘  │
│                         │                            │
│  ┌─────────────────────────────────────────────────┐  │
│  │                    Redis                         │  │
│  │              redis:7-alpine :6379                │  │
│  └─────────────────────────────────────────────────┘  │
│                         │                            │
│  ┌─────────────────────────────────────────────────┐  │
│  │                  RabbitMQ                        │  │
│  │          rabbitmq:3-management :5672 :15672      │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│  │  Auth  │ │Account │ │  Fund  │ │Portfolio│ │ Trade  │
│  │ :8001  │ │ :8002  │ │ :8003  │ │  :8004 │ │ :8005  │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘
│                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │                   Nginx                          │  │
│  │                  :80 → 路由                      │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 6.2 资源配置

| 服务 | CPU | 内存 | 端口 |
|------|-----|------|------|
| MySQL | 1核 | 512MB | 3306 |
| Redis | 0.5核 | 256MB | 6379 |
| RabbitMQ | 0.5核 | 256MB | 5672/15672 |
| auth-service | 0.5核 | 256MB | 8001 |
| account-service | 0.5核 | 256MB | 8002 |
| fund-service | 0.5核 | 256MB | 8003 |
| portfolio-service | 0.5核 | 256MB | 8004 |
| trade-service | 0.5核 | 256MB | 8005 |
| Nginx | 0.25核 | 128MB | 80 |

---

## 7. 扩展性设计

### 7.1 水平扩展

```
Nginx (upstream)
    ├── auth-service-1:8001
    ├── auth-service-2:8001
    └── auth-service-3:8001
```

### 7.2 缓存策略

| 数据类型 | 缓存时间 | 淘汰策略 |
|---------|---------|---------|
| 基金列表 | 5分钟 | LRU |
| 基金净值 | 1分钟 | LRU |
| 用户信息 | 15分钟 | LRU |
| JWT Token | Token过期时间 | - |

### 7.3 消息队列

| 队列名称 | 用途 | 消费者 |
|---------|------|--------|
| trade_orders | 异步处理交易 | trade-service |
| notifications | 消息推送 | notification-service |
| risk_assessment | 风评异步处理 | account-service |

---

## 8. 监控设计

### 8.1 监控指标

| 指标 | 告警阈值 |
|------|---------|
| 服务可用性 | < 99.9% |
| API响应时间 | P95 > 200ms |
| 数据库连接 | > 80% |
| Redis内存 | > 70% |
| 队列积压 | > 1000 |

### 8.2 日志规范

```json
{
  "timestamp": "ISO8601",
  "level": "INFO/WARN/ERROR",
  "service": "service-name",
  "trace_id": "uuid",
  "message": "日志内容",
  "context": {}
}
```
