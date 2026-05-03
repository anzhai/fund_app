# 基金App测试指南

## 快速测试流程

### 1. 启动后端服务

```bash
cd backend
./scripts/start-local.sh
```

等待所有服务启动完成（约30秒）。

### 2. 验证服务状态

```bash
# 检查所有容器运行状态
docker-compose ps

# 应该看到以下服务都在运行:
# - mysql
# - redis  
# - rabbitmq
# - auth-service
# - account-service
# - fund-service
# - portfolio-service
# - trade-service
# - nginx
```

### 3. 初始化Mock数据

```bash
# 导入12只基金数据
curl -X POST http://localhost:8003/fund/seed

# 预期返回: {"message":"成功导入12只基金数据"}
```

### 4. 测试API接口

#### 用户注册
```bash
curl -X POST http://localhost:8001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "13800138000",
    "password": "123456",
    "user_type": "direct_sales"
  }'

# 预期返回: {access_token, refresh_token}
```

#### 用户登录
```bash
curl -X POST http://localhost:8001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "login_type": "phone",
    "identifier": "13800138000",
    "password": "123456"
  }'

# 保存返回的token用于后续请求
```

#### 获取基金列表
```bash
curl http://localhost:8003/fund/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 预期返回: 基金列表数组
```

#### 开户
```bash
curl -X POST http://localhost:8002/account/open \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "id_card": "110101199001011234",
    "real_name": "张三",
    "id_card_expire": "2030-01-01",
    "trade_password": "123456"
  }'

# 预期返回: {"message":"开户成功","account_id":1}
```

#### 风险测评
```bash
# 获取问题
curl http://localhost:8002/risk/questions

# 提交答案
curl -X POST http://localhost:8002/risk/submit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "answers": [
      {"id": 1, "score": 20},
      {"id": 2, "score": 25},
      {"id": 3, "score": 25},
      {"id": 4, "score": 25},
      {"id": 5, "score": 25}
    ]
  }'

# 预期返回: {"risk_level":"C3","expire_date":"2027-05-03"}
```

#### 基金购买
```bash
curl -X POST http://localhost:8005/trade/purchase \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "fund_code": "000001",
    "amount": 1000.00,
    "pay_method": "wallet"
  }'

# 预期返回: 交易订单详情
```

#### 钱包充值
```bash
curl -X POST http://localhost:8005/wallet/recharge \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "amount": 10000.00
  }'

# 预期返回: {"message":"充值成功","balance":10000.00}
```

---

## Flutter App测试

### 1. 启动Flutter应用

```bash
cd frontend/fund_app
flutter pub get
flutter run
```

### 2. 测试流程

#### 注册/登录
1. 打开App，进入登录页
2. 输入手机号：13800138000
3. 输入密码：123456
4. 点击登录
5. 验证是否跳转到首页

#### 查看基金
1. 点击底部"基金"Tab
2. 查看基金列表
3. 尝试筛选功能（按类型、风险等级）
4. 搜索基金（输入代码或名称）

#### 开户流程
1. 点击"我的"Tab
2. 如果未开户，会提示去开户
3. 输入身份证信息
4. 设置交易密码
5. 验证开户成功

#### 风险测评
1. 在"我的"页面点击"风险测评"
2. 回答7个问题
3. 提交后查看风险等级

#### 基金购买
1. 在基金列表选择一只基金
2. 进入交易页（买入Tab）
3. 输入基金代码和金额
4. 选择支付方式
5. 确认购买

#### 定投计划
1. 在"交易"页切换到"定投"Tab
2. 点击创建定投
3. 填写定投信息
4. 查看定投列表

---

## 常见测试场景

### 场景1: 新用户完整流程
```
注册 → 登录 → 开户 → 风险测评 → 充值 → 买基金 → 查看持仓
```

### 场景2: 定投投资
```
登录 → 选择基金 → 创建定投计划 → 查看定投列表 → 暂停/恢复定投
```

### 场景3: 风险管理
```
登录 → 风险测评(C1保守型) → 尝试购买R5高风险基金 → 验证被拦截
```

### 场景4: 钱包操作
```
登录 → 充值10000元 → 普通取现5000元 → 快速取现2000元 → 查看余额
```

---

## Swagger文档测试

访问以下地址进行可视化API测试：

- 认证服务: http://localhost:8001/docs
- 账户服务: http://localhost:8002/docs
- 基金服务: http://localhost:8003/docs
- 组合服务: http://localhost:8004/docs
- 交易服务: http://localhost:8005/docs

在Swagger UI中可以直接测试所有API接口。

---

## 数据库查询测试

```bash
# 连接MySQL
docker-compose exec mysql mysql -ufund_user -pfund_pass fund_app

# 常用查询
SELECT * FROM users;
SELECT * FROM accounts;
SELECT * FROM funds LIMIT 5;
SELECT * FROM trade_orders ORDER BY created_at DESC LIMIT 10;
SELECT * FROM wallets;
SELECT * FROM sip_plans;
```

---

## 日志查看

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f auth-service
docker-compose logs -f trade-service

# 查看最近100行
docker-compose logs --tail=100 fund-service
```

---

## 性能测试

### 使用Apache Bench测试

```bash
# 测试基金列表接口
ab -n 1000 -c 10 http://localhost:8003/fund/

# 预期: QPS > 100, 平均响应时间 < 100ms
```

### 使用wrk测试

```bash
wrk -t12 -c400 -d30s http://localhost:8003/fund/
```

---

## 错误处理测试

### 测试无效Token
```bash
curl http://localhost:8003/fund/ \
  -H "Authorization: Bearer invalid_token"

# 预期: 401 Unauthorized
```

### 测试参数验证
```bash
curl -X POST http://localhost:8001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "invalid_phone",
    "password": "123"
  }'

# 预期: 422 Validation Error
```

### 测试风险不匹配
```bash
# C1用户购买R5基金应被拒绝
curl -X POST http://localhost:8005/trade/purchase \
  -H "Authorization: Bearer USER_C1_TOKEN" \
  -d '{
    "fund_code": "000009",
    "amount": 1000,
    "pay_method": "wallet"
  }'

# 预期: 400 风险不匹配
```

---

## 移动端测试

### iOS模拟器
```bash
flutter run -d ios
```

### Android模拟器
```bash
flutter run -d android
```

### 真机调试
```bash
# 查看可用设备
flutter devices

# 指定设备运行
flutter run -d <device_id>
```

---

## 测试检查清单

- [ ] 所有Docker服务正常运行
- [ ] API文档可访问
- [ ] Mock数据已导入
- [ ] 用户可以注册和登录
- [ ] Token刷新正常工作
- [ ] 开户流程完整
- [ ] 风险测评可以提交
- [ ] 基金列表正确显示
- [ ] 基金筛选功能正常
- [ ] 基金购买成功
- [ ] 钱包充值成功
- [ ] 钱包取现成功
- [ ] 定投计划创建成功
- [ ] 交易记录正确显示
- [ ] Flutter App可以运行
- [ ] App登录功能正常
- [ ] App页面导航流畅

---

## 故障排查

### 服务无法启动
```bash
# 检查端口占用
lsof -i :8001
lsof -i :8002
# ...

# 重启服务
docker-compose restart auth-service
```

### 数据库连接失败
```bash
# 检查MySQL状态
docker-compose ps mysql

# 查看MySQL日志
docker-compose logs mysql
```

### Flutter编译错误
```bash
# 清理缓存
flutter clean
flutter pub get

# 检查Flutter环境
flutter doctor
```

---

**测试完成后，请记录发现的问题并反馈给开发团队。**
