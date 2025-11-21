# SpringBootWithOtel TodoApp + OpenObserve Demo

一个使用 Java 17、Spring Boot 3、OpenTelemetry 与 OpenObserve 的 Todo 应用演示：
- REST API + 内置 Web 页面（`/`）操作全部接口
- OpenTelemetry Java Agent 自动采集 + 代码手动埋点（SDK）
- 通过 OTLP（默认 gRPC）将 Traces/Metrics/Logs 上报到 OpenObserve
- docker-compose 一键启动（OpenObserve + 应用）

## 快速开始
- 启动服务（首次会构建镜像）：
  - `docker compose up -d --build`
- 访问地址：
  - OpenObserve UI：`http://localhost:5080/`（默认用户：`admin@example.com` / `admin123`）
  - 应用 Web 页面：`http://localhost:8080/`
  - 健康检查：`http://localhost:8080/actuator/health`

## 环境变量（安全建议）
为避免在 compose 中硬编码敏感信息，已改为从环境变量读取：
- `ZO_ROOT_USER_EMAIL`、`ZO_ROOT_USER_PASSWORD`（OpenObserve 初始用户）
- `OO_ORG`、`OO_STREAM_NAME`、`OO_AUTH_BASIC`（OTLP 认证与路由）

示例（PowerShell）：
```
$env:ZO_ROOT_USER_EMAIL='admin@example.com'
$env:ZO_ROOT_USER_PASSWORD='admin123'
$env:OO_ORG='default'
$env:OO_STREAM_NAME='default'
$env:OO_AUTH_BASIC='Basic '+[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('admin@example.com:admin123'))

docker compose up -d --build
```

## OTLP 配置（gRPC 默认）
- 在 `docker-compose.yml` 中，应用容器通过 Java Agent 以 gRPC 上报：
  - `OTEL_EXPORTER_OTLP_PROTOCOL=grpc`
  - `OTEL_EXPORTER_OTLP_ENDPOINT=http://openobserve:5081`
  - `OTEL_EXPORTER_OTLP_HEADERS="Authorization=${OO_AUTH_BASIC},organization=${OO_ORG:-default},stream-name=${OO_STREAM_NAME:-default}"`
- 关闭应用内 Micrometer 的导出以避免重复：
  - `MANAGEMENT_TRACING_ENABLED=false`
  - `OTLP_METRICS_ENABLED=false`

可切换为 HTTP/OTLP（调试友好）：
- `OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf`
- `OTEL_EXPORTER_OTLP_ENDPOINT=http://openobserve:5080/api/${OO_ORG:-default}`
- 头部包含 `Authorization` 与 `stream-name`

## API 概览
- 列表：`GET /api/todos`
- 创建：`POST /api/todos`（示例 body）
  - `{ "title": "Demo", "description": "OpenTelemetry", "completed": false }`
- 查询：`GET /api/todos/{id}`
- 更新：`PUT /api/todos/{id}`
- 删除：`DELETE /api/todos/{id}`
- 清空：`DELETE /api/todos`

## Web 页面
- 入口：`/`（`src/main/resources/static/index.html`）
- 功能：列表、创建、更新、删除、清空、按 ID 查询
- 操作后在页面底部显示最近一次 `Trace-Id`，可在 OpenObserve 按 traceId 检索

## 可观测性
- 自动探针：Java Agent（HTTP/JPA/线程等）
- 手动埋点：`todo.create.manual`、`todo.update.manual`（`src/main/java/com/example/todo/service/TodoService.java`）
- 响应头返回 `X-Trace-Id`（`src/main/java/com/example/todo/web/TraceIdResponseFilter.java`）
- 日志格式带 `trace_id`/`span_id`（`src/main/resources/logback-spring.xml`）

## 脚本
- 运行（Agent + 应用内 Micrometer）：`scripts/run-with-otel-agent.ps1/.cmd`
- 仅 Agent（禁用应用内导出）：`scripts/run-with-otel-agent-only.ps1/.cmd`
- API 演示：`scripts/demo-call.ps1`、`scripts/demo-get.ps1`

## 开发与构建
- 本地构建：`mvn -q -DskipTests package`
- 清理容器：
  - 停止：`docker compose down`
  - 移除含数据：`docker compose down -v`

## 注意事项
- 默认密码仅用于演示，请在实际环境替换为强密码，并通过环境或 CI/CD 注入。
- Windows 上用 `curl.exe` 发送 JSON 时需注意双引号转义；建议使用 Web 页面或 Postman 测试。