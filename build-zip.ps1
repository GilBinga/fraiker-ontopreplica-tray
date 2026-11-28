# Monta o zip da release em dist\. Uso: .\build-zip.ps1 1.3.0
param([Parameter(Mandatory)][string]$Version)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
$files = @(
    'Fraiker Tools.ps1'
    'Fraiker Tools.vbs'
    'Abrir réplicas.bat'
    'Desinstalar.bat'
    'assets\fraiker-tools.ico'
    'README.md'
    'LICENSE'
)

$dist = Join-Path $root 'dist'
$stage = Join-Path $dist 'stage'
$app = Join-Path $stage 'Fraiker Tools'
$zip = Join-Path $dist "Fraiker-Tools-OnTopReplica-v$Version.zip"

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
if (Test-Path $zip) { Remove-Item $zip -Force }
foreach ($f in $files) {
    $dst = Join-Path $app $f
    New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
    Copy-Item (Join-Path $root $f) $dst
}
# ZipFile grava nomes com acento em UTF-8 (o Compress-Archive do PowerShell 5.1 estraga o "é")
[IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip, 'Optimal', $false)
Remove-Item $stage -Recurse -Force
Write-Host "Gerado: $zip"
