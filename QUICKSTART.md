# 基金理财应用 - 快速启动指南

## 一、环境依赖

### 1.1 必须安装的软件

| 软件 | 版本 | 说明 | 安装命令 |
|------|------|------|---------|
| Python | ≥ 3.9 | 后端运行环境 | `brew install python@3.11` |
| Flutter | ≥ 3.0 | 前端框架 | `brew install flutter` |
| Git | - | 代码管理 | `brew install git` |
| Docker | ≥ 20.10 | 容器化环境 | 官网下载 |
| Docker Compose | ≥ 1.29 | 多容器编排 | `brew install docker-compose` |

### 1.2 Python 依赖 (后端)

```bash
# 安装 Python 虚拟环境工具
brew install pyenv pyenv-virtualenv

# 创建虚拟环境
cd backend
pyenv install 3.11.9
pyenv virtualenv fund-app
pyenv activate fund-app

# 安装通用依赖
pip install fastapi uvicorn sqlalchemy pymysql redis pydantic pydantic-settings
pip install python-jose passlib python-multipart

# 或使用 requirements.txt
pip install -r auth-service/requirements.txt
```

### 1.3 Flutter 依赖 (前端)

```bash
# 安装 Flutter (macOS)
brew install flutter

# 验证安装
flutter doctor
```

---

## 二、快速启动后端服务

### 方式A: Docker Compose 一键启动（推荐）

```bash
# 1. 进入后端目录
cd backend

# 2. 复制环境配置
cp .env.example .env

# 3. 启动所有服务（包括MySQL/Redis/Nginx）
docker-compose up -d

# 4. 查看服务状态
docker-compose ps

# 5. 查看日志
docker-compose logs -f auth-service
```

**启动后服务地址：**
- Nginx网关: http://localhost:80
- auth-service: http://localhost:8001
- account-service: http://localhost:8002
- fund-service: http://localhost:8003
- portfolio-service: http://localhost:8004
- trade-service: http://localhost:8005
- MySQL: localhost:3306
- Redis: localhost:6379
- RabbitMQ: localhost:5672

### 方式B: 本地开发模式（逐个启动服务）

```bash
# 1. 前置条件：本地运行 MySQL + Redis
#    - MySQL: localhost:3306
#    - Redis: localhost:6379

# 2. 设置环境变量
export DATABASE_URL="mysql+pymysql://root:root123@localhost:3306/fund_app"
export REDIS_URL="redis://localhost:6379"
export JWT_SECRET="dev-secret-key-for-local-dev"

# 3. 创建数据库（首次）
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS fund_app;"
mysql -u root -p fund_app < init.sql

# 4. 启动各个服务（分别开终端）
# 终端1 - Auth服务
cd backend/auth-service
uvicorn main:app --reload --port 8001

# 终端2 - Account服务
cd backend/account-service
uvicorn main:app --reload --port 8002

# 终端3 - Fund服务
cd backend/fund-service
uvicorn main:app --reload --port 8003

# 终端4 - Portfolio服务
cd backend/portfolio-service
uvicorn main:app --reload --port 8004

# 终端5 - Trade服务
cd backend/trade-service
uvicorn main:app --reload --port 8005
```

### 方式C: 使用启动脚本（Linux/macOS）

```bash
cd backend

# 赋予执行权限
chmod +x scripts/start-local.sh

# 启动所有后端服务（需要先启动MySQL和Redis）
./scripts/start-local.sh
```

---

## 三、快速启动前端应用

### 前置条件

```bash
# 安装 Flutter 依赖
cd frontend/fund_app

# 获取依赖
flutter pub get
```

### 启动开发服务器

```bash
cd frontend/fund_app

# 启动开发服务器（热重载）
flutter run

# 指定设备
flutter run -d "iPhone 15 Pro"

# 启动Web版本
flutter run -d chrome

# 发布版本构建
flutter build ios --release
flutter build apk --release
```

### iOS 模拟器操作

```bash
# 查看可用模拟器
xcr simctl list devices

# 启动模拟器
open -a Simulator

# 运行APP
flutter run -d "iPhone 15 Pro"
```

---

## 四、快速验证

### 4.1 后端健康检查

```bash
# 检查各服务健康状态
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
curl http://localhost:8004/health
curl http://localhost:8005/health
```

### 4.2 API 接口测试

```bash
# 测试注册接口
curl -X POST http://localhost:8001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800138000","password":"Test123!","sms_code":"123456"}'

# 测试登录接口
curl -X POST http://localhost:8001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login_type":"phone","phone":"13800138000","password":"Test123!"}'
```

### 4.3 Flutter 验证

```bash
cd frontend/fund_app
flutter doctor        # 检查环境
flutter run          # 启动应用
```

---

## 五、环境变量说明

### .env 文件配置

```bash
# 数据库
MYSQL_ROOT_PASSWORD=your_password
MYSQL_DATABASE=fund_app
MYSQL_USER=fund_user
MYSQL_PASSWORD=your_password
DATABASE_URL=mysql+pymysql://fund_user:your_password@mysql:3306/fund_app

# Redis
REDIS_URL=redis://redis:6379

# JWT (必须设置复杂的随机字符串)
JWT_SECRET=generate_with_openssl_rand_base64_32

# RabbitMQ
RABBITMQ_USER=guest
RABBITMQ_PASS=your_password
```

### 生成安全密钥

```bash
# 生成随机密钥
openssl rand -base64 32
```

---

## 六、常见问题排查

### Docker 相关

```bash
# 查看容器日志
docker-compose logs -f [service-name]

# 重启单个服务
docker-compose restart [service-name]

# 清理重建
docker-compose down -v
docker-compose up -d

# 进入容器排查
docker exec -it fund-app_mysql_1 /bin/bash
docker exec -it fund-app_redis_1 /bin/bash
```

### 端口占用

```bash
# 检查端口占用
lsof -i :8001
lsof -i :3306
lsof -i :6379

# 杀死占用进程
kill -9 $(lsof -t -i :8001)
```

### Python 虚拟环境

```bash
# 退出虚拟环境
deactivate

# 删除重建
rm -rf ~/.pyenv/versions/fund-app
pyenv virtualenv 3.11.9 fund-app
```

### Flutter 问题

```bash
# 清理缓存
flutter clean
flutter pub get

# 重建
flutter pub upgrade
```

---

## 七、项目结构速查

```
fund-app/
├── backend/
│   ├── docker-compose.yml     # Docker编排
│   ├── init.sql              # 数据库初始化
│   ├── .env.example         # 环境变量示例
│   ├── auth-service/        # 认证服务 (8001)
│   ├── account-service/     # 账户服务 (8002)
│   ├── fund-service/        # 基金服务 (8003)
│   ├── portfolio-service/   # 组合服务 (8004)
│   ├── trade-service/       # 交易服务 (8005)
│   └── gateway/             # Nginx配置
│
├── frontend/
│   └── fund_app/            # Flutter应用
│       └── lib/
│           └── main.dart    # 入口文件
│
└── docs/                    # 项目文档
```

---

## 八、一句话启动命令

```bash
# 后端（Docker方式）
cd backend && cp .env.example .env && docker-compose up -d

# 前端
cd frontend/fund_app && flutter pub get && flutter run
```

**访问地址：**
- 后端API: http://localhost:8001 ~ 8005
- 前端: http://localhost:8080 (Web)
