# Git工作流程 - 基金理财应用

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 1. 分支策略

### 1.1 分支结构

```
main (生产分支)
  │
  ├── develop (开发分支)
  │     │
  │     ├── feature/* (功能分支)
  │     ├── bugfix/* (修复分支)
  │     └── release/* (发布分支)
  │
  └── hotfix/* (热修复分支)
```

### 1.2 分支命名

| 分支类型 | 命名规范 | 示例 |
|---------|---------|------|
| 功能分支 | feature/{功能名} | feature/user-login |
| 修复分支 | bugfix/{问题描述} | bugfix/login-timeout |
| 发布分支 | release/{版本号} | release/v1.0.0 |
| 热修复分支 | hotfix/{问题描述} | hotfix/critical-bug |

---

## 2. 工作流程

### 2.1 功能开发流程

```bash
# 1. 从develop创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/user-registration

# 2. 开发功能
git add .
git commit -m "feat(auth): add user registration"

# 3. 推送到远程
git push origin feature/user-registration

# 4. 创建Pull Request
# 通过GitHub/GitLab界面创建PR

# 5. Code Review后合并到develop
git checkout develop
git merge feature/user-registration
git push origin develop

# 6. 删除功能分支
git branch -d feature/user-registration
git push origin --delete feature/user-registration
```

### 2.2 Bug修复流程

```bash
# 1. 从develop创建修复分支
git checkout develop
git pull origin develop
git checkout -b bugfix/login-timeout

# 2. 修复问题
git add .
git commit -m "fix(auth): resolve login timeout issue"

# 3. 推送到远程
git push origin bugfix/login-timeout

# 4. 创建Pull Request
# 合并到develop
```

### 2.3 热修复流程

```bash
# 1. 从main创建热修复分支
git checkout main
git pull origin main
git checkout -b hotfix/critical-security

# 2. 紧急修复
git add .
git commit -m "hotfix: critical security patch"

# 3. 直接合并到main和develop
git checkout main
git merge hotfix/critical-security
git push origin main

git checkout develop
git merge hotfix/critical-security
git push origin develop

# 4. 删除热修复分支
git branch -d hotfix/critical-security
```

---

## 3. Commit规范

### 3.1 提交格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 3.2 示例

```
feat(auth): implement biometric authentication

- add fingerprint login support
- add face recognition login
- add device biometric enrollment flow

Closes #123
Closes #456
```

### 3.3 常用Type

| Type | Description |
|------|-------------|
| feat | 新功能 |
| fix | Bug修复 |
| docs | 文档变更 |
| style | 代码格式(不影响功能) |
| refactor | 重构(非新功能/修复) |
| test | 测试相关 |
| chore | 构建/工具变更 |

---

## 4. Pull Request规范

### 4.1 PR模板

```markdown
## 概述
[简要描述本次变更]

## 变更内容
- [变更点1]
- [变更点2]

## 影响范围
[说明影响的功能/模块]

## 测试情况
- [ ] 本地测试通过
- [ ] 单元测试通过
- [ ] 集成测试通过

## 截图/录屏
[如有UI变更，附上截图]
```

### 4.2 Code Review检查项

- [ ] 代码符合编码规范
- [ ] 有适当的单元测试
- [ ] 没有明显的性能问题
- [ ] 安全检查通过
- [ ] API设计合理
- [ ] 数据库变更有迁移脚本

---

## 5. 版本发布流程

### 5.1 版本号规范

```
主版本号.次版本号.修订号
v1.0.0

- 主版本号: 不兼容的API变更
- 次版本号: 向后兼容的新功能
- 修订号: 向后兼容的问题修复
```

### 5.2 发布流程

```bash
# 1. 创建发布分支
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# 2. 更新版本号
# 修改相关配置文件

# 3. 提交变更
git commit -m "chore: bump version to v1.0.0"

# 4. 合并到main
git checkout main
git merge release/v1.0.0
git tag v1.0.0
git push origin main --tags

# 5. 合并回develop
git checkout develop
git merge release/v1.0.0
git push origin develop

# 6. 删除发布分支
git branch -d release/v1.0.0
```

---

## 6. Tag管理

```bash
# 创建Tag
git tag -a v1.0.0 -m "Release v1.0.0"

# 推送Tag
git push origin v1.0.0

# 查看所有Tag
git tag -l

# 删除本地Tag
git tag -d v1.0.0

# 删除远程Tag
git push origin --delete v1.0.0
```
