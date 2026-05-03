# 基金理财应用 - 项目文档索引

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 一、需求与设计阶段

| 文档 | 文件 | 说明 |
|------|------|------|
| 产品需求文档(PRD) | [PRD.md](PRD.md) | 产品功能需求、业务流程、用户类型 |
| UI设计规范 | [ui-spec.md](ui-spec.md) | 颜色体系、字体、组件、页面清单 |
| 架构设计 | [architecture.md](architecture.md) | 系统架构、服务划分、部署拓扑 |
| 数据库设计 | [database.md](database.md) | ER图、表结构、索引设计 |
| 接口定义 | [api-contract.md](api-contract.md) | API契约、请求/响应格式、错误码 |
| 业务流程图 | [flowchart.md](flowchart.md) | 核心业务流程图 |

---

## 二、测试阶段

| 文档 | 文件 | 说明 |
|------|------|------|
| 测试策略 | [test-strategy.md](test-strategy.md) | 测试方法论、测试用例、测试数据 |

---

## 三、开发阶段

| 文档 | 文件 | 说明 |
|------|------|------|
| 编码规范 | [coding-standard.md](coding-standard.md) | Python编码规范、API设计规范 |
| Git工作流程 | [git-workflow.md](git-workflow.md) | 分支策略、提交规范、发布流程 |

---

## 四、部署与运维阶段

| 文档 | 文件 | 说明 |
|------|------|------|
| 部署手册 | [deployment-manual.md](deployment-manual.md) | Docker/K8S部署、回滚方案 |
| 运维手册 | [ops-manual.md](ops-manual.md) | 日常运维、监控告警、应急预案 |
| 非功能需求 | [non-functional.md](non-functional.md) | 性能、安全、兼容性需求 |

---

## 五、文档更新记录

| 日期 | 更新内容 | 更新人 |
|------|---------|--------|
| 2026-05-03 | 初始版本，基于测试用例文档生成 | - |

---

## 六、快速索引

### 按模块查找

- **用户/认证**: PRD.md, api-contract.md (认证接口)
- **开户/风评**: PRD.md, flowchart.md, test-strategy.md
- **基金交易**: PRD.md, flowchart.md, api-contract.md (交易接口)
- **银行卡**: PRD.md, database.md, test-strategy.md
- **积分会员**: PRD.md, flowchart.md, test-strategy.md
- **运维部署**: deployment-manual.md, ops-manual.md

### 按阶段查找

- **需求分析**: PRD.md, flowchart.md, non-functional.md
- **技术设计**: architecture.md, database.md, api-contract.md
- **开发实现**: coding-standard.md, git-workflow.md
- **测试验证**: test-strategy.md
- **部署上线**: deployment-manual.md
- **生产运维**: ops-manual.md

---

## 七、相关资源

| 资源 | 位置 |
|------|------|
| 后端代码 | `../backend/` |
| 前端代码 | `../frontend/` |
| 数据库SQL | `../backend/init.sql` |
| Docker配置 | `../backend/docker-compose.yml` |
| 测试用例 | `../../Downloads/APP端Flutter版本全量测试点0108.xlsx` |
