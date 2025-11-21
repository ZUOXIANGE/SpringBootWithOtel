param()
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$agentVersion = '1.56.0'
$agentDir = Join-Path $PWD '.otel'
$agentJar = Join-Path $agentDir 'opentelemetry-javaagent.jar'
if (-not (Test-Path $agentDir)) { New-Item -ItemType Directory -Path $agentDir | Out-Null }
if (-not (Test-Path $agentJar)) {
  $url = "https://repo1.maven.org/maven2/io/opentelemetry/javaagent/opentelemetry-javaagent/$agentVersion/opentelemetry-javaagent-$agentVersion.jar"
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
  if ($env:OTEL_AGENT_PATH -and (Test-Path $env:OTEL_AGENT_PATH)) { Copy-Item $env:OTEL_AGENT_PATH $agentJar -Force }
  if (-not (Test-Path $agentJar)) { try { Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $agentJar } catch { & curl.exe -L -o $agentJar $url } }
}
$org = if ($env:OO_ORG) { $env:OO_ORG } else { 'default' }
$base = if ($env:OO_BASE) { $env:OO_BASE } else { 'http://localhost:5080' }
$endpoint = "$base/api/$org"
$stream = if ($env:OO_STREAM_NAME) { $env:OO_STREAM_NAME } else { 'default' }
$auth = $env:OO_AUTH_BASIC
$env:OTEL_EXPORTER_OTLP_PROTOCOL = 'http/protobuf'
$env:OTEL_EXPORTER_OTLP_ENDPOINT = $endpoint
if ($auth) { $env:OTEL_EXPORTER_OTLP_HEADERS = "Authorization=$auth,stream-name=$stream" } else { $env:OTEL_EXPORTER_OTLP_HEADERS = "stream-name=$stream" }
$env:OTEL_TRACES_EXPORTER = 'otlp'
$env:OTEL_METRICS_EXPORTER = 'otlp'
$env:OTEL_LOGS_EXPORTER = 'otlp'
if (-not $env:OTEL_RESOURCE_ATTRIBUTES) { $env:OTEL_RESOURCE_ATTRIBUTES = 'service.name=todo-app' }
mvn -q -DskipTests package
if (Test-Path $agentJar) { java -javaagent:$agentJar -jar target/todo-otel-openobserve-0.0.1-SNAPSHOT.jar } else { java -jar target/todo-otel-openobserve-0.0.1-SNAPSHOT.jar }