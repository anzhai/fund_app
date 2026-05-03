# 编码规范 - 基金理财应用

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 1. Python编码规范

### 1.1 代码格式化

| 工具 | 配置 |
|------|------|
| Black | line-length: 100, target-version: py39 |
| isort | profile: black, multi_line_summary: bracket |

```bash
# 安装工具
pip install black isort mypy flake8

# 格式化代码
black .

# 排序导入
isort .
```

### 1.2 类型注解

```python
# Good
def get_user(user_id: int) -> User:
    return User.query.get(user_id)

# Bad
def get_user(user_id):
    return User.query.get(user_id)
```

### 1.3 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类名 | PascalCase | UserAccount |
| 函数名 | snake_case | get_user_info |
| 变量名 | snake_case | user_id |
| 常量 | UPPER_SNAKE | MAX_RETRY_COUNT |
| 私有变量 | _leading_underscore | _internal_var |
| 类型别名 | PascalCase | UserId |

---

## 2. API设计规范

### 2.1 路由命名

```python
# 路由规范
@app.get("/api/v1/users/{user_id}")      # 获取用户
@app.post("/api/v1/users")               # 创建用户
@app.put("/api/v1/users/{user_id}")      # 更新用户
@app.delete("/api/v1/users/{user_id}")    # 删除用户
```

### 2.2 请求/响应模型

```python
from pydantic import BaseModel, Field
from typing import Optional

class UserLoginRequest(BaseModel):
    phone: str = Field(..., pattern=r"^1[3-9]\d{9}$")
    password: str = Field(..., min_length=6)

class UserResponse(BaseModel):
    user_id: int
    phone: str
    is_verified: bool

    class Config:
        from_attributes = True
```

---

## 3. 数据库规范

### 3.1 SQLAlchemy模型

```python
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    phone = Column(String(11), unique=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
```

### 3.2 迁移脚本命名

```
V{version}__{description}.sql
V1.0.0__initial_schema.sql
V1.1.0__add_pension_card.sql
```

---

## 4. Git提交规范

### 4.1 提交格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 4.2 Type类型

| 类型 | 说明 |
|------|------|
| feat | 新功能 |
| fix | Bug修复 |
| docs | 文档变更 |
| style | 代码格式 |
| refactor | 重构 |
| test | 测试相关 |
| chore | 构建/工具 |

### 4.3 示例

```
feat(auth): add biometric login support

- add fingerprint authentication
- add face recognition support
- integrate with system biometric API

Closes #123
```

---

## 5. 日志规范

```python
import logging

logger = logging.getLogger(__name__)

# Good
logger.info("用户登录成功", extra={"user_id": user_id, "ip": ip})
logger.warning("密码错误", extra={"user_id": user_id, "attempts": attempts})
logger.error("数据库连接失败", extra={"error": str(e)})

# Bad
print(f"用户{user_id}登录成功")
```
