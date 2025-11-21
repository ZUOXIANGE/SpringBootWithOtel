param(
  [string]$Base = 'http://localhost:5080',
  [string]$Org = 'default',
  [string]$Stream = 'default',
  [string]$User = 'admin@example.com',
  [string]$Password = 'admin123'
)
$ErrorActionPreference = 'Stop'
$global:ProgressPreference = 'SilentlyContinue'
$env:OO_BASE = $Base
$env:OO_ORG = $Org
$env:OO_STREAM_NAME = $Stream
$b = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$User:$Password"))
$env:OO_AUTH_BASIC = "Basic $b"
Write-Host "OO_BASE=$($env:OO_BASE)"
Write-Host "OO_ORG=$($env:OO_ORG)"
Write-Host "OO_STREAM_NAME=$($env:OO_STREAM_NAME)"
Write-Host "OO_AUTH_BASIC set"