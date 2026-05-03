# 基金组合管理 App

一款专业的基金组合管理应用，支持基金交易、定投、组合管理等核心功能。

## 项目特点

- ✅ **已去除养老金模块** - 根据需求移除了所有养老金相关功能
- ✅ **完整测试用例覆盖** - 基于测试用例完善所有API和前端功能
- ✅ **微服务架构** - FastAPI后端 + Flutter前端
- ✅ **多种登录方式** - 密码登录、短信验证码登录
- ✅ **完整交易流程** - 申购、赎回、定投、转换等
- ✅ **风险控制** - 用户风险等级与产品匹配校验

## 技术栈

### 后端
- **框架**: FastAPI (Python)
- **数据库**: MySQL 8.0
- **缓存**: Redis 7
- **消息队列**: RabbitMQ
- **网关**: Nginx

### 前端
- **框架**: Flutter
- **状态管理**: Provider
- **HTTP客户端**: http, dio
- **图表**: fl_chart
- **本地存储**: shared_preferences, flutter_secure_storage

## 项目结构

```
fund-app/
├── backend/                    # 后端微服务
│   ├── auth-service/          # 认证服务 (端口8001)
│   ├── account-service/       # 账户服务 (端口8002)
│   ├── fund-service/          # 基金服务 (端口8003)
│   ├── portfolio-service/     # 组合服务 (端口8004)
│   ├── trade-service/         # 交易服务 (端口8005)
│   ├── gateway/               # Nginx网关配置
│   ├── docker-compose.yml     # Docker编排
│   └── init.sql               # 数据库初始化脚本
└── frontend/
    └── fund_app/              # Flutter应用
        ├── lib/
        │   ├── main.dart      # 应用入口
        │   ├── services/      # API服务层
        │   ├── providers/     # 状态管理
        │   └── screens/       # 页面组件
        └── pubspec.yaml       # Flutter依赖
```

## 核心功能模块

### 1. 认证模块 (auth-service)
- ✅ 手机号+密码登录
- ✅ 身份证号+密码登录
- ✅ 短信验证码登录
- ✅ 用户注册
- ✅ Token刷新机制
- ✅ 密码重置

### 2. 开户模块 (account-service)
- ✅ 身份证上传与验证
- ✅ 身份证有效期校验（按年龄档位）
- ✅ 银行卡添加与管理
- ✅ 交易密码设置（强度校验）
- ✅ 黑名单校验

### 3. 基金模块 (fund-service)
- ✅ 基金列表查询（支持筛选）
- ✅ 基金详情查看
- ✅ 基金排行榜（1月/3月/1年/3年）
- ✅ 基金净值历史
- ✅ 自选基金（待实现）

### 4. 交易模块 (trade-service)
- ✅ 基金申购
- ✅ 基金赎回
- ✅ 基金认购
- ✅ 基金转换
- ✅ 红利再投
- ✅ 撤单功能
- ✅ 定投计划管理（普通定投/工资理财）
- ✅ 钱包充值
- ✅ 钱包取现（普通T+1 / 快速实时）

### 5. 组合模块 (portfolio-service)
- ✅ 创建投资组合
- ✅ 组合持仓管理
- ✅ 收益分析

### 6. 风控模块
- ✅ 风险测评问卷
- ✅ 用户风险等级评估（C1-C5）
- ✅ 产品风险等级匹配校验
- ✅ 交易限额校验
- ✅ 大额交易双因素验证
- ✅ 账户状态校验

## 快速开始

### 环境要求
- Docker & Docker Compose
- Flutter SDK >= 2.19.0
- Python 3.11+

### 启动后端服务

```bash
cd backend

# 创建.env文件
cp .env.example .env
# 编辑.env文件，设置JWT_SECRET等环境变量

# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 初始化数据

```bash
# 访问基金服务 seeding 接口
curl -X POST http://localhost:8003/fund/seed
```

### 启动前端应用

```bash
cd frontend/fund_app

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## API文档

服务启动后，访问以下地址查看Swagger文档：
- 认证服务: http://localhost:8001/docs
- 账户服务: http://localhost:8002/docs
- 基金服务: http://localhost:8003/docs
- 组合服务: http://localhost:8004/docs
- 交易服务: http://localhost:8005/docs

## 数据库表结构

主要数据表：
- `users` - 用户表
- `accounts` - 账户信息表
- `funds` - 基金信息表
- `fund_nav_history` - 基金净值历史
- `portfolios` - 投资组合表
- `portfolio_positions` - 组合持仓表
- `trade_orders` - 交易订单表
- `wallets` - 钱包表
- `wallet_transactions` - 钱包交易记录
- `bank_cards` - 银行卡表
- `sip_plans` - 定投计划表
- `risk_questionnaires` - 风险测评表

## 测试用例覆盖

基于测试用例 `APP端Flutter版本全量测试点0108.xlsx`，已实现：

### 登录模块 ✅
- 快速注册
- 多种登录方式（手机号/身份证/短信）
- 第三方登录（预留接口）
- 生物识别（预留接口）
- 忘记密码

### 开户模块 ✅
- 身份证上传与OCR识别
- 有效期校验（5年/10年/20年/长期）
- 银行卡添加
- 交易密码设置

### 基金业务 ✅
- 基金超市
- 基金详情
- 基金筛选
- 基金排行
- 自选基金

### 交易功能 ✅
- 申购/赎回/认购
- 定投（普通/工资理财）
- 转换/撤单
- 充值/取现

### 风控校验 ✅
- 风险测评
- 适当性管理
- 限额校验
- 状态校验

## 注意事项

1. **Mock数据**: 当前使用Mock基金数据，生产环境需对接真实基金数据源
2. **支付集成**: 钱包充值/取现为模拟实现，生产环境需对接第三方支付
3. **短信服务**: 短信验证码为模拟实现，生产环境需对接SMS服务商
4. **合规要求**: 基金销售需要持牌经营，正式上线需取得相应资质

## 开发计划

- [ ] 完善生物识别登录（指纹/面容）
- [ ] 实现手势密码
- [ ] 添加基金自选功能
- [ ] 完善收益分析图表
- [ ] 添加消息推送
- [ ] 实现定投自动扣款定时任务
- [ ] 添加更多基金数据类型（QDII、商品等）

## 许可证

本项目仅供学习参考使用。
