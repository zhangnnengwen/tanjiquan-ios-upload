param(
    [string] $IpaPath
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$encryptedIpaRelativePath = "ipa\__UNI__15CD4B6_0618111726.ipa.enc"
$encryptedIpaGitPath = "ipa/__UNI__15CD4B6_0618111726.ipa.enc"
$encryptedIpaPath = Join-Path $repoRoot $encryptedIpaRelativePath
$encryptScriptPath = Join-Path $repoRoot "scripts\encrypt_ipa.rb"

function Stop-WithMessage {
    param([string] $Message)
    Write-Host ""
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

function Invoke-Step {
    param(
        [string] $Title,
        [scriptblock] $Script
    )

    Write-Host ""
    Write-Host "==> $Title" -ForegroundColor Cyan
    & $Script
}

function Get-RubyPath {
    $bundledRuby = "C:\Ruby33-x64\bin\ruby.exe"
    if (Test-Path -LiteralPath $bundledRuby) {
        return $bundledRuby
    }

    $rubyCommand = Get-Command ruby -ErrorAction SilentlyContinue
    if ($null -ne $rubyCommand) {
        return $rubyCommand.Source
    }

    Stop-WithMessage "Ruby was not found. Install Ruby or check C:\Ruby33-x64\bin\ruby.exe."
}

function Get-PlainPasswordFromSecureString {
    param([securestring] $SecurePassword)

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

Set-Location $repoRoot

Write-Host "Tanjiquan iOS IPA upload helper" -ForegroundColor Green
Write-Host "Repository: $repoRoot"

if ([string]::IsNullOrWhiteSpace($IpaPath)) {
    $IpaPath = Read-Host "Drag the new .ipa file here, then press Enter"
}

$IpaPath = $IpaPath.Trim().Trim('"')
if ([string]::IsNullOrWhiteSpace($IpaPath)) {
    Stop-WithMessage "No IPA path was provided."
}

if (-not (Test-Path -LiteralPath $IpaPath)) {
    Stop-WithMessage "IPA file does not exist: $IpaPath"
}

$resolvedIpaPath = (Resolve-Path -LiteralPath $IpaPath).Path
if ([IO.Path]::GetExtension($resolvedIpaPath).ToLowerInvariant() -ne ".ipa") {
    Stop-WithMessage "Selected file is not an .ipa file: $resolvedIpaPath"
}

if (-not (Test-Path -LiteralPath $encryptScriptPath)) {
    Stop-WithMessage "Encryption script was not found: $encryptScriptPath"
}

$rubyPath = Get-RubyPath

Invoke-Step "Checking Git repository" {
    $gitRoot = (& git rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "This folder is not a Git repository."
    }

    $gitRootResolved = (Resolve-Path -LiteralPath $gitRoot).Path
    $repoRootResolved = (Resolve-Path -LiteralPath $repoRoot).Path
    if ($gitRootResolved -ne $repoRootResolved) {
        Stop-WithMessage "Unexpected Git root: $gitRootResolved"
    }

    $status = @(& git status --porcelain)
    if ($status.Count -gt 0) {
        Write-Host "Current Git changes:"
        $status | ForEach-Object { Write-Host "  $_" }
        Stop-WithMessage "Please commit or clean current changes before running this helper."
    }
}

Invoke-Step "Updating local main branch" {
    & git pull --ff-only origin main
    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "git pull failed. Check the network or resolve local branch state."
    }
}

$hadPasswordInEnv = -not [string]::IsNullOrEmpty($env:IPA_DECRYPT_PASSWORD)
$temporaryPassword = $null

if (-not $hadPasswordInEnv) {
    $securePassword = Read-Host "Enter IPA_DECRYPT_PASSWORD from Codemagic" -AsSecureString
    $temporaryPassword = Get-PlainPasswordFromSecureString $securePassword
    if ([string]::IsNullOrWhiteSpace($temporaryPassword)) {
        Stop-WithMessage "IPA_DECRYPT_PASSWORD cannot be empty."
    }
    $env:IPA_DECRYPT_PASSWORD = $temporaryPassword
}

try {
    Invoke-Step "Encrypting IPA" {
        & $rubyPath $encryptScriptPath $resolvedIpaPath $encryptedIpaPath
        if ($LASTEXITCODE -ne 0) {
            Stop-WithMessage "IPA encryption failed."
        }
        if (-not (Test-Path -LiteralPath $encryptedIpaPath)) {
            Stop-WithMessage "Encrypted IPA was not created: $encryptedIpaPath"
        }
        Get-Item -LiteralPath $encryptedIpaPath | Select-Object FullName, Length, LastWriteTime | Format-List
    }
}
finally {
    if (-not $hadPasswordInEnv) {
        Remove-Item Env:\IPA_DECRYPT_PASSWORD -ErrorAction SilentlyContinue
        $temporaryPassword = $null
    }
}

Invoke-Step "Committing encrypted IPA" {
    & git add -- $encryptedIpaGitPath
    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "git add failed."
    }

    $statusAfterAdd = @(& git status --porcelain -- $encryptedIpaGitPath)
    if ($statusAfterAdd.Count -eq 0) {
        Write-Host "Encrypted IPA did not change. Nothing to commit."
        exit 0
    }

    $commitMessage = "chore: update encrypted ipa"
    & git commit -m $commitMessage
    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "git commit failed."
    }
}

Invoke-Step "Pushing to GitHub" {
    & git push origin main
    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "git push failed. Check the network, then run this helper again."
    }
}

Write-Host ""
Write-Host "Upload helper finished." -ForegroundColor Green
Write-Host "Next step: open Codemagic and click Start new build."
Write-Host "Codemagic app: https://codemagic.io/app"
