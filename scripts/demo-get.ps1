param(
  [string]$BaseUrl = 'http://localhost:8080'
)
$ErrorActionPreference = 'Stop'
$list = Invoke-RestMethod -UseBasicParsing -Method Get -Uri "$BaseUrl/api/todos"
$list | ConvertTo-Json -Compress | Write-Output