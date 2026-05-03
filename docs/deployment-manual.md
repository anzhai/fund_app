# 部署手册 - 基金理财应用

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 1. 环境信息

### 1.1 环境配置

| 环境 | 用途 | 域名 | 备注 |
|------|------|------|------|
| DEV | 开发测试 | localhost | 本地开发 |
| TEST | 功能测试 | test.fundapp.com | 测试环境 |
| UAT | 用户验收 | uat.fundapp.com | 预生产 |
| PROD | 生产环境 | fundapp.com | 正式环境 |

### 1.2 服务器配置

| 服务 | 规格 | 数量 | 备注 |
|------|------|------|------|
| Gateway/Nginx | 2核4G | 2 | 负载均衡 |
| MySQL | 4核8G | 1 | 主从架构 |
| Redis | 2核4G | 2 | 主从架构 |
| RabbitMQ | 2核4G | 1 | 单机 |
| auth-service | 1核2G | 3 | 集群 |
| account-service | 1核2G | 3 | 集群 |
| fund-service | 1核2G | 3 | 集群 |
| portfolio-service | 1核2G | 3 | 集群 |
| trade-service | 1核2G | 3 | 集群 |

---

## 2. 部署前准备

### 2.1 依赖检查

```bash
# 检查Docker版本
docker --version  # >= 20.10

# 检查Docker Compose版本
docker-compose --version  # >= 1.29

# 检查kubectl (K8S环境)
kubectl version
```

### 2.2 环境变量配置

```bash
# 创建环境变量文件
cp .env.example .env

# 配置必要的环境变量
cat > .env << EOF
# Database
DATABASE_URL=mysql+pymysql://fund_user:fund_pass@mysql:3306/fund_app

# Redis
REDIS_URL=redis://redis:6379

# JWT
JWT_SECRET=your-secret-key-here
JWT_ALGORITHM=HS256

# 服务端口
AUTH_SERVICE_PORT=8001
ACCOUNT_SERVICE_PORT=8002
FUND_SERVICE_PORT=8003
PORTFOLIO_SERVICE_PORT=8004
TRADE_SERVICE_PORT=8005
EOF
```

### 2.3 镜像构建

```bash
# 构建所有服务镜像
cd backend

# 构建auth-service
docker build -t fund-app/auth-service:latest ./auth-service

# 构建account-service
docker build -t fund-app/account-service:latest ./account-service

# 构建fund-service
docker build -t fund-app/fund-service:latest ./fund-service

# 构建portfolio-service
docker build -t fund-app/portfolio-service:latest ./portfolio-service

# 构建trade-service
docker build -t fund-app/trade-service:latest ./trade-service

# 推送到镜像仓库 (如有)
docker push fund-app/auth-service:latest
# ... 其他服务
```

---

## 3. Docker Compose部署

### 3.1 启动基础设施

```bash
# 启动MySQL、Redis、RabbitMQ
docker-compose up -d mysql redis rabbitmq

# 等待MySQL就绪
docker-compose ps mysql  # 查看状态
docker-compose logs mysql | grep "ready for connections"
```

### 3.2 初始化数据库

```bash
# 执行初始化SQL
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app < backend/init.sql

# 验证表结构
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app -e "SHOW TABLES;"
```

### 3.3 启动业务服务

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看单个服务日志
docker-compose logs -f auth-service
```

### 3.4 启动Nginx网关

```bash
# 启动Nginx
docker-compose up -d nginx

# 验证Nginx配置
docker exec fund-app_nginx_1 nginx -t
```

---

## 4. Kubernetes部署 (可选)

### 4.1 创建命名空间

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: fund-app
  labels:
    name: fund-app
```

### 4.2 部署配置文件

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
```

### 4.3 部署服务

```bash
# 部署MySQL StatefulSet
kubectl apply -f k8s/mysql.yaml

# 部署Redis
kubectl apply -f k8s/redis.yaml

# 部署RabbitMQ
kubectl apply -f k8s/rabbitmq.yaml

# 部署业务服务
kubectl apply -f k8s/auth-service.yaml
kubectl apply -f k8s/account-service.yaml
kubectl apply -f k8s/fund-service.yaml
kubectl apply -f k8s/portfolio-service.yaml
kubectl apply -f k8s/trade-service.yaml

# 部署Nginx Ingress
kubectl apply -f k8s/nginx.yaml
```

### 4.4 验证部署

```bash
# 检查Pod状态
kubectl get pods -n fund-app

# 检查Service
kubectl get svc -n fund-app

# 查看服务日志
kubectl logs -f deployment/auth-service -n fund-app
```

---

## 5. 部署后验证

### 5.1 健康检查

```bash
# 检查各服务健康状态
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
curl http://localhost:8004/health
curl http://localhost:8005/health

# 期望返回: {"status": "healthy", "service": "xxx"}
```

### 5.2 API接口测试

```bash
# 测试注册接口
curl -X POST http://localhost/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800138000","password":"Test123!","sms_code":"123456"}'

# 测试登录接口
curl -X POST http://localhost/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login_type":"phone","phone":"13800138000","password":"Test123!"}'
```

### 5.3 数据库验证

```bash
# 验证用户数据
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app -e "SELECT id, phone, user_type FROM users LIMIT 1;"

# 验证基金数据
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app -e "SELECT fund_code, fund_name FROM funds LIMIT 3;"
```

### 5.4 Redis验证

```bash
# 验证Redis连接
docker exec fund-app_redis_1 redis-cli ping
# 期望返回: PONG
```

---

## 6. 回滚方案

### 6.1 Docker Compose回滚

```bash
# 查看历史容器
docker-compose ps

# 回滚到上一个版本
docker-compose down
docker-compose pull  # 重新拉取旧版本镜像
docker-compose up -d

# 或者使用特定版本标签
docker tag fund-app/auth-service:old fund-app/auth-service:latest
docker-compose up -d
```

### 6.2 数据库回滚

```bash
# 全量备份
docker exec fund-app_mysql_1 mysqldump -ufund_user -pfund_pass fund_app > backup_$(date +%Y%m%d).sql

# 恢复数据
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app < backup_20260503.sql
```

### 6.3 Kubernetes回滚

```bash
# 回滚Deployment
kubectl rollout undo deployment/auth-service -n fund-app

# 查看回滚历史
kubectl rollout history deployment/auth-service -n fund-app

# 回滚到特定版本
kubectl rollout undo deployment/auth-service --to-revision=2 -n fund-app
```

---

## 7. 部署检查清单

### 7.1 部署前检查

| 检查项 | 状态 | 备注 |
|-------|------|------|
| 环境变量已配置 | □ | |
| 基础镜像已准备 | □ | |
| 数据库迁移已执行 | □ | |
| 防火墙/端口已开放 | □ | |
| 监控告警已配置 | □ | |
| 日志收集已配置 | □ | |

### 7.2 部署后检查

| 检查项 | 状态 | 备注 |
|-------|------|------|
| 所有Pod/容器运行正常 | □ | |
| 健康检查通过 | □ | |
| 服务间通信正常 | □ | |
| 数据库读写正常 | □ | |
| Redis缓存正常 | □ | |
| 接口响应正常 | □ | |
| 前端页面可访问 | □ | |
| 日志输出正常 | □ | |

### 7.3 上线检查

| 检查项 | 状态 | 备注 |
|-------|------|------|
| 功能测试通过 | □ | |
| 性能测试通过 | □ | |
| 安全扫描通过 | □ | |
| 数据验证通过 | □ | |
| 监控告警正常 | □ | |
| 备份已验证 | □ | |

---

## 8. 故障排查

### 8.1 服务无法启动

```bash
# 查看日志
docker-compose logs <service-name>

# 检查端口占用
netstat -tlnp | grep <port>

# 检查依赖服务
docker-compose ps
```

### 8.2 数据库连接失败

```bash
# 检查MySQL日志
docker-compose logs mysql

# 测试连接
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass -e "SELECT 1;"

# 检查连接数
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass -e "SHOW STATUS LIKE 'Threads_connected';"
```

### 8.3 服务间通信失败

```bash
# 检查网络
docker network ls
docker network inspect fund-app_backend

# 测试服务间通信
docker exec fund-app_auth-service_1 curl http://account-service:8002/health

# 检查DNS解析
docker exec fund-app_auth-service_1 nslookup account-service
```

---

## 9. 联系方式

| 角色 | 联系方式 | 职责 |
|------|---------|------|
| 技术负责人 | - | 架构决策 |
| 运维负责人 | - | 部署支持 |
| DBA | - | 数据库支持 |
| 安全负责人 | - | 安全相关 |
