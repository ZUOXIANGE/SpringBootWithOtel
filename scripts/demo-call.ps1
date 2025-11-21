param(
  [string]$BaseUrl = 'http://localhost:8080'
)
$ErrorActionPreference = 'Stop'
$body = @{
  title = 'Demo'
  description = 'OpenTelemetry'
  completed = $false
} | ConvertTo-Json
$resp = Invoke-RestMethod -UseBasicParsing -Method Post -Uri "$BaseUrl/api/todos" -ContentType 'application/json' -Body $body
$resp | ConvertTo-Json -Compress | Write-Output