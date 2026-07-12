#!/usr/bin/env pwsh
# Runtime symbol-check for the vendored swiftmaestro package.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ZlibInc,
    [Parameter(Mandatory = $true)][string]$ZlibLib,
    [string]$ScratchPath = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$pass = 'PASS adaptivecards-swiftmaestro-runtime'

$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($machinePath) { $env:Path = "$machinePath;$userPath" }
$sdk = [Environment]::GetEnvironmentVariable('SDKROOT', 'User')
if ($sdk) { $env:SDKROOT = $sdk }

if (-not (Test-Path (Join-Path $ZlibInc 'zlib.h'))) { throw "zlib.h missing under $ZlibInc" }
if (-not (Test-Path $ZlibLib)) { throw "zlib library directory missing: $ZlibLib" }

Push-Location $PSScriptRoot
try {
    if (-not $ScratchPath) {
        $drive = (Get-Item $PSScriptRoot).PSDrive.Name
        $ScratchPath = "${drive}:\b\smd"
    }
    New-Item -ItemType Directory -Force -Path $ScratchPath | Out-Null
    $flags = @(
        '--scratch-path', $ScratchPath,
        '-Xcc', "-I$ZlibInc",
        '-Xswiftc', "-I$ZlibInc",
        '-Xlinker', "/LIBPATH:$ZlibLib"
    )

    Write-Host '== build swiftmaestro runtime demo =='
    & swift build -c debug @flags
    if ($LASTEXITCODE -ne 0) { throw "demo build failed ($LASTEXITCODE)" }

    $binPath = (& swift build -c debug --show-bin-path @flags).Trim()
    $exe = Join-Path $binPath 'AdaptiveCardsDemo.exe'
    if (-not (Test-Path $exe)) { $exe = Join-Path $binPath 'AdaptiveCardsDemo' }
    if (-not (Test-Path $exe)) { throw "AdaptiveCardsDemo executable missing under $binPath" }

    Write-Host '== run swiftmaestro runtime demo =='
    $output = & $exe 2>&1 | Out-String
    $code = $LASTEXITCODE
    $output.Trim() | Write-Host
    if ($code -ne 0) { throw "demo exited $code" }
    if ($output -notmatch [regex]::Escape($pass)) { throw "'$pass' not found" }

    Write-Host "smoke OK: '$pass' observed" -ForegroundColor Green
}
finally {
    Pop-Location
}
