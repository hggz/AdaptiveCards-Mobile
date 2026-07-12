<#
.SYNOPSIS
    Assemble the local Windows target sysroot used by the bridge's WSL lane.
.DESCRIPTION
    Swift's Windows target is split across Windows.sdk, Visual Studio, and
    Windows Kits. This script discovers exact matching components and stages a
    generated, case-insensitive header/module-map overlay under dist/xwin-sdk.
    Nothing under dist is committed.
#>
[CmdletBinding()]
param(
    [string]$OutDir = 'dist/xwin-sdk',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$bridge = Split-Path -Parent $PSScriptRoot
Set-Location $bridge
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')
$env:SDKROOT = [Environment]::GetEnvironmentVariable('SDKROOT', 'User')

if ($PSVersionTable.Platform -ne 'Win32NT' -and $env:OS -ne 'Windows_NT') {
    throw 'prepare-xwin-sdk.ps1 must run on Windows.'
}

function Assert-Directory([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label not found: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Copy-Tree([string]$Source, [string]$Destination) {
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    & robocopy $Source $Destination /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -gt 7) {
        throw "robocopy failed ($LASTEXITCODE): $Source -> $Destination"
    }
}

function Convert-ToWslPath([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    if ($full -notmatch '^([A-Za-z]):\\(.*)$') {
        throw "Only local drive paths are supported: $full"
    }
    return "/mnt/$($Matches[1].ToLowerInvariant())/$($Matches[2].Replace('\', '/'))"
}

function Quote-Sh([string]$Value) {
    if ($Value.Contains("'")) { throw "Cannot shell-quote path containing apostrophe: $Value" }
    return "'$Value'"
}

$swift = (Get-Command swift.exe -ErrorAction Stop).Source
$versionLine = (& $swift --version | Select-Object -First 1)
if ($versionLine -notmatch 'Swift version ([0-9]+\.[0-9]+\.[0-9]+)') {
    throw "Could not parse Swift version from: $versionLine"
}
$swiftVersion = $Matches[1]
$sdk = Assert-Directory $env:SDKROOT 'Swift Windows SDKROOT'
$settings = Get-Content (Join-Path $sdk 'SDKSettings.json') -Raw | ConvertFrom-Json
if ([string]$settings.Version -ne $swiftVersion) {
    throw "Swift compiler $swiftVersion does not match Windows SDK $($settings.Version)."
}

$swiftRoot = (Resolve-Path (Join-Path (Split-Path $swift) '..\..\..\..')).Path
$runtime = Assert-Directory (Join-Path $swiftRoot "Runtimes\$swiftVersion\usr\bin") 'Swift runtime DLL directory'

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $vswhere)) { throw "vswhere not found: $vswhere" }
$vsInstall = (& $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | Select-Object -First 1)
if (-not $vsInstall) { throw 'No Visual Studio installation with x64 C++ tools found.' }
$msvc = Get-ChildItem (Join-Path $vsInstall 'VC\Tools\MSVC') -Directory |
    Where-Object { (Test-Path (Join-Path $_.FullName 'include')) -and (Test-Path (Join-Path $_.FullName 'lib\x64')) } |
    Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1
if (-not $msvc) { throw "No complete MSVC toolset found under $vsInstall" }
$msvcRoot = $msvc.FullName

$kitRoot = Assert-Directory (Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10') 'Windows SDK root'
$kit = Get-ChildItem (Join-Path $kitRoot 'Include') -Directory |
    Where-Object {
        (Test-Path (Join-Path $_.FullName 'ucrt')) -and
        (Test-Path (Join-Path $_.FullName 'shared')) -and
        (Test-Path (Join-Path $_.FullName 'um')) -and
        (Test-Path (Join-Path $_.FullName 'winrt')) -and
        (Test-Path (Join-Path $kitRoot "Lib\$($_.Name)\ucrt\x64")) -and
        (Test-Path (Join-Path $kitRoot "Lib\$($_.Name)\um\x64"))
    } | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1
if (-not $kit) { throw "No complete x64 Windows SDK found under $kitRoot" }
$kitVersion = $kit.Name

$out = if ([IO.Path]::IsPathRooted($OutDir)) { $OutDir } else { Join-Path $bridge $OutDir }
$out = [IO.Path]::GetFullPath($out)
$include = Join-Path $out 'include'
$stampPath = Join-Path $out 'stamp.json'
$stamp = ([ordered]@{
    swiftVersion = $swiftVersion
    sdk = $sdk
    msvc = $msvcRoot
    kitRoot = $kitRoot
    kitVersion = $kitVersion
    runtime = $runtime
} | ConvertTo-Json -Depth 3)
$existing = if (Test-Path $stampPath) { Get-Content $stampPath -Raw } else { '' }
$mapsPresent = (Test-Path (Join-Path $include 'msvc\module.modulemap')) -and
               (Test-Path (Join-Path $include 'ucrt\module.modulemap')) -and
               (Test-Path (Join-Path $include 'shared\module.modulemap')) -and
               (Test-Path (Join-Path $include 'um\module.modulemap'))

if ($Force -or -not $mapsPresent -or $existing.Trim() -ne $stamp.Trim()) {
    Write-Host '== staging case-insensitive Windows header overlay ==' -ForegroundColor Cyan
    if (Test-Path $include) { Remove-Item -Recurse -Force $include }
    Copy-Tree (Join-Path $msvcRoot 'include') (Join-Path $include 'msvc')
    foreach ($name in @('ucrt', 'shared', 'um', 'winrt')) {
        Copy-Tree (Join-Path $kitRoot "Include\$kitVersion\$name") (Join-Path $include $name)
    }
    Copy-Item (Join-Path $sdk 'usr\share\vcruntime.modulemap') (Join-Path $include 'msvc\module.modulemap') -Force
    Copy-Item (Join-Path $sdk 'usr\share\ucrt.modulemap') (Join-Path $include 'ucrt\module.modulemap') -Force
    Copy-Item (Join-Path $sdk 'usr\share\winsdk_shared.modulemap') (Join-Path $include 'shared\module.modulemap') -Force
    Copy-Item (Join-Path $sdk 'usr\share\winsdk_um.modulemap') (Join-Path $include 'um\module.modulemap') -Force
} else {
    Write-Host '== Windows header overlay already current ==' -ForegroundColor DarkGray
}

New-Item -ItemType Directory -Force $out | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($stampPath, ($stamp.TrimEnd() + "`n"), $utf8)
$envLines = @(
    "SWIFT_VERSION=$(Quote-Sh $swiftVersion)",
    "WINDOWS_SDK=$(Quote-Sh (Convert-ToWslPath $sdk))",
    "XWIN_SYSROOT=$(Quote-Sh (Convert-ToWslPath $out))",
    "MSVC_ROOT=$(Quote-Sh (Convert-ToWslPath $msvcRoot))",
    "WINDOWS_KIT_ROOT=$(Quote-Sh (Convert-ToWslPath $kitRoot))",
    "WINDOWS_KIT_VERSION=$(Quote-Sh $kitVersion)",
    "SWIFT_RUNTIME=$(Quote-Sh (Convert-ToWslPath $runtime))"
) -join "`n"
[IO.File]::WriteAllText((Join-Path $out 'paths.env'), ($envLines + "`n"), $utf8)
Write-Host "PASS bridge xwin SDK prepared: Swift $swiftVersion / MSVC $($msvc.Name) / Windows SDK $kitVersion" -ForegroundColor Green
