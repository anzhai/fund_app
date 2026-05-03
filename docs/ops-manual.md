# 运维手册 - 基金理财应用

## 文档版本

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.0 | 2026-05-03 | - | 初始版本 |

---

## 1. 日常运维

### 1.1 巡检流程

#### 每日巡检

| 检查项 | 检查方法 | 正常指标 |
|--------|---------|---------|
| 服务可用性 | curl健康检查端点 | HTTP 200 |
| API响应时间 | 查看监控面板 | P95 < 200ms |
| 数据库连接 | SHOW STATUS LIKE 'Threads_connected' | < 80% |
| Redis内存 | INFO memory | used_memory_human < 70% |
| 磁盘空间 | df -h | 使用率 < 80% |
| 日志异常 | grep ERROR logs | 无新增ERROR |

```bash
#!/bin/bash
# daily_check.sh

echo "=== 服务健康检查 ==="
for svc in auth account fund portfolio trade; do
  port=$((8000 + $(echo $svc | grep -o . | wc -l) + 1))
  # 简化处理
  curl -s http://localhost:${port}/health || echo "$svc: DOWN"
done

echo "=== 数据库连接 ==="
docker exec fund-app_mysql_1 mysql -ufund_user -pfund_pass -e "SHOW STATUS LIKE 'Threads_connected';"

echo "=== Redis内存 ==="
docker exec fund-app_redis_1 redis-cli INFO memory | grep used_memory_human

echo "=== 磁盘空间 ==="
df -h /
```

#### 每周巡检

| 检查项 | 说明 |
|--------|------|
| 备份验证 | 验证最近一次备份可恢复 |
| 日志分析 | 分析一周错误日志趋势 |
| 性能报表 | 生成周性能报表 |
| 容量规划 | 评估资源使用趋势 |

### 1.2 常用运维命令

#### Docker Compose命令

```bash
# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f auth-service

# 重启单个服务
docker-compose restart auth-service

# 重启所有服务
docker-compose restart

# 停止所有服务
docker-compose down

# 启动所有服务
docker-compose up -d

# 进入服务容器
docker-compose exec auth-service /bin/bash

# 重建单个服务
docker-compose up -d --no-deps auth-service
```

#### 数据库命令

```bash
# 连接数据库
docker exec -it fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app

# 查看当前连接数
SHOW STATUS LIKE 'Threads_connected';

# 查看慢查询
SHOW VARIABLES LIKE 'slow_query_log%';
SELECT * FROM mysql.slow_log;

# 查看进程列表
SHOW PROCESSLIST;

# 手动执行备份
docker exec fund-app_mysql_1 mysqldump -ufund_user -pfund_pass fund_app > backup_$(date +%Y%m%d).sql
```

#### Redis命令

```bash
# 连接Redis
docker exec -it fund-app_redis_1 redis-cli

# 查看内存使用
INFO memory

# 查看key数量
DBSIZE

# 查看所有key
KEYS *

# 清除所有key
FLUSHALL

# 查看客户端连接
CLIENT LIST
```

---

## 2. 监控告警

### 2.1 监控指标

#### 系统层指标

| 指标 | 告警阈值 | 严重程度 |
|------|---------|---------|
| CPU使用率 | > 80% | 警告 |
| CPU使用率 | > 95% | 严重 |
| 内存使用率 | > 80% | 警告 |
| 内存使用率 | > 95% | 严重 |
| 磁盘使用率 | > 80% | 警告 |
| 磁盘使用率 | > 95% | 严重 |
| 网络流量 | 异常峰值 | 警告 |

#### 应用层指标

| 指标 | 告警阈值 | 严重程度 |
|------|---------|---------|
| API响应时间P95 | > 200ms | 警告 |
| API响应时间P95 | > 500ms | 严重 |
| API错误率 | > 1% | 警告 |
| API错误率 | > 5% | 严重 |
| 服务可用性 | < 99.9% | 严重 |
| JVM堆内存 | > 80% | 警告 |

#### 数据库指标

| 指标 | 告警阈值 | 严重程度 |
|------|---------|---------|
| 连接数 | > 80% max_connections | 警告 |
| 连接数 | > 95% max_connections | 严重 |
| 查询响应时间 | > 100ms | 警告 |
| 死锁次数 | > 0 | 严重 |
| 主从延迟 | > 1s | 警告 |

### 2.2 告警配置

```yaml
# Prometheus告警规则示例
groups:
  - name: fund-app-alerts
    rules:
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "服务 {{ $labels.instance }} 已停止"

      - alert: HighResponseTime
        expr: http_request_duration_seconds_p95 > 0.2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "API响应时间过高"

      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "错误率过高"
```

### 2.3 监控大盘

| 大盘名称 | 监控内容 |
|---------|---------|
| 系统概览 | 服务可用性、API响应、错误率 |
| 数据库监控 | 连接数、查询性能、慢查询 |
| Redis监控 | 内存使用、命中率、客户端连接 |
| 业务监控 | 交易量、注册量、开户量 |
| 支付监控 | 交易金额、成功率、失败原因 |

---

## 3. 日志管理

### 3.1 日志规范

```json
{
  "timestamp": "2026-05-03T10:00:00.000Z",
  "level": "INFO/WARN/ERROR",
  "service": "auth-service",
  "trace_id": "550e8400-e29b-41d4-a716-446655440000",
  "span_id": "abc123",
  "message": "用户登录成功",
  "context": {
    "user_id": 1,
    "login_type": "phone",
    "ip": "192.168.1.100"
  }
}
```

### 3.2 日志级别

| 级别 | 场景 |
|------|------|
| DEBUG | 开发调试信息 |
| INFO | 正常业务流程日志 |
| WARN | 警告信息(非致命) |
| ERROR | 错误信息(需关注) |

### 3.3 日志收集

```yaml
# filebeat配置示例
filebeat.inputs:
  - type: container
    paths:
      - /var/lib/docker/containers/*/*.log
    processors:
      - add_kubernetes_metadata:
          host: ${NODE_NAME}
          matchers:
            - logs_path:
                logs_path: "/var/lib/docker/containers/"

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
```

### 3.4 日志分析

```bash
# 查看最近1小时错误日志
grep "ERROR" logs/app.log | tail -100

# 统计错误类型分布
grep "ERROR" logs/app.log | cut -d':' -f3 | sort | uniq -c

# 查看特定用户操作日志
grep "user_id=123" logs/app.log

# 性能日志分析
grep "慢查询" logs/mysql.log
```

---

## 4. 应急预案

### 4.1 服务故障处理

#### 服务宕机

```bash
# 1. 确认故障
docker-compose ps

# 2. 查看日志
docker-compose logs <service-name>

# 3. 重启服务
docker-compose restart <service-name>

# 4. 验证恢复
curl http://localhost:<port>/health
```

#### 数据库故障

```bash
# 1. 检查MySQL状态
docker-compose ps mysql

# 2. 查看MySQL日志
docker-compose logs mysql

# 3. 如果MySQL无法启动，尝试重启
docker-compose restart mysql

# 4. 如果数据损坏，执行恢复
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app < backup_latest.sql
```

### 4.2 数据异常处理

#### 用户数据异常

```bash
# 1. 确认异常数据
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app -e "SELECT * FROM users WHERE id=123;"

# 2. 查看操作日志
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app -e "SELECT * FROM trace_records WHERE user_id=123 ORDER BY created_at DESC LIMIT 10;"

# 3. 根据情况修复或回滚
```

#### 订单数据异常

```bash
# 1. 确认订单状态
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app -e "SELECT * FROM trade_orders WHERE id=456;"

# 2. 查看订单处理日志
grep "order_id=456" logs/trade-service.log

# 3. 根据业务规则处理
```

### 4.3 安全事件处理

#### 异常登录检测

```bash
# 1. 查看登录日志
grep "login" logs/auth-service.log | grep "fail" | tail -50

# 2. 查看异地登录
grep "异地登录" logs/auth-service.log

# 3. 封禁异常IP
iptables -A INPUT -s <suspicious_ip> -j DROP

# 4. 通知安全团队
```

#### 数据泄露处理

```bash
# 1. 确认泄露范围
# 2. 立即封禁相关账号
# 3. 保留证据日志
# 4. 上报安全团队
# 5. 通知受影响用户
```

### 4.4 灾难恢复

#### 服务完全中断

```bash
# 1. 评估影响范围
# 2. 启动紧急响应流程
# 3. 从备份恢复数据库
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app < backup_latest.sql

# 4. 重启所有服务
docker-compose down
docker-compose up -d

# 5. 验证服务
# 6. 通知用户
```

---

## 5. 备份恢复

### 5.1 备份策略

| 备份类型 | 频率 | 保留时间 | 方式 |
|---------|------|---------|------|
| 全量备份 | 每日 | 30天 | mysqldump |
| 增量备份 | 每小时 | 7天 | binlog |
| 文件备份 | 每日 | 30天 | rsync |
| 配置备份 | 每次变更 | 90天 | git |

### 5.2 备份脚本

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/data/backup"
DATE=$(date +%Y%m%d)

# 数据库备份
docker exec fund-app_mysql_1 mysqldump -ufund_user -pfund_pass fund_app > $BACKUP_DIR/fund_app_$DATE.sql

# 压缩
gzip $BACKUP_DIR/fund_app_$DATE.sql

# 删除30天前备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "Backup completed: fund_app_$DATE.sql.gz"
```

### 5.3 恢复流程

```bash
# 1. 停止服务
docker-compose stop

# 2. 恢复数据库
gunzip < backup_20260503.sql.gz | docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app

# 3. 启动服务
docker-compose start

# 4. 验证数据
docker exec -i fund-app_mysql_1 mysql -ufund_user -pfund_pass fund_app -e "SELECT COUNT(*) FROM users;"
```

---

## 6. 容量管理

### 6.1 资源使用评估

| 资源 | 当前使用 | 峰值 | 扩容阈值 |
|------|---------|------|---------|
| CPU | 40% | 75% | 70% |
| 内存 | 60% | 80% | 80% |
| 磁盘 | 50% | 60% | 80% |
| 数据库连接 | 30% | 50% | 70% |

### 6.2 扩容流程

```bash
# 1. 评估扩容需求
# 2. 申请资源
# 3. 执行扩容
docker-compose up -d --scale auth-service=5

# 4. 验证负载均衡
# 5. 更新监控
```

---

## 7. SOP标准操作流程

### 7.1 服务重启SOP

```
适用场景: 服务异常需要重启
预计时间: 5分钟

步骤:
1. 确认影响范围 (哪些服务/用户受影响)
2. 通知相关人员 (技术负责人/客服)
3. 执行重启
   docker-compose restart <service-name>
4. 验证服务健康
   curl http://localhost:<port>/health
5. 确认业务恢复
6. 记录日志

回滚:
- 如果重启失败，检查日志定位问题
- 如果无法恢复，联系开发团队
```

### 7.2 数据库维护SOP

```
适用场景: 数据库表优化/迁移
预计时间: 30分钟

步骤:
1. 备份当前数据
2. 通知相关人员
3. 创建维护窗口
4. 执行维护
5. 验证数据完整性
6. 关闭维护窗口
7. 通知完成

注意:
- 维护窗口期间停止写入
- 保持数据库只读
```

### 7.3 版本发布SOP

```
适用场景: 新版本发布
预计时间: 1小时

步骤:
1. 准备发布计划
2. 开发/测试完成确认
3. 代码Review通过
4. 执行预发布验证
5. 备份当前版本
6. 执行发布
7. 健康检查
8. 监控观察
9. 发布完成通知

回滚:
- 如果发布失败
- docker-compose down
- docker-compose pull <previous-version>
- docker-compose up -d
```

---

## 8. 联系方式

| 角色 | 姓名 | 电话 | 邮箱 |
|------|------|------|------|
| 技术负责人 | - | - | - |
| 运维负责人 | - | - | - |
| DBA | - | - | - |
| 安全负责人 | - | - | - |
| 值班手机 | - | - | - |

---

## 9. 附录

### 9.1 常用端口

| 服务 | 端口 |
|------|------|
| Nginx | 80/443 |
| auth-service | 8001 |
| account-service | 8002 |
| fund-service | 8003 |
| portfolio-service | 8004 |
| trade-service | 8005 |
| MySQL | 3306 |
| Redis | 6379 |
| RabbitMQ | 5672/15672 |

### 9.2 日志路径

| 服务 | 日志路径 |
|------|---------|
| auth-service | /var/log/fund-app/auth.log |
| account-service | /var/log/fund-app/account.log |
| fund-service | /var/log/fund-app/fund.log |
| portfolio-service | /var/log/fund-app/portfolio.log |
| trade-service | /var/log/fund-app/trade.log |
| nginx | /var/log/nginx/ |
