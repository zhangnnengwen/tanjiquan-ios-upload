$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$ps1Path = Join-Path $repoRoot "upload-new-ipa.ps1"
$batPath = Join-Path $repoRoot "upload-new-ipa.bat"

function Assert-True {
    param(
        [bool] $Condition,
        [string] $Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

Assert-True (Test-Path -LiteralPath $ps1Path) "Missing upload-new-ipa.ps1"
Assert-True (Test-Path -LiteralPath $batPath) "Missing upload-new-ipa.bat"

$ps1 = Get-Content -LiteralPath $ps1Path -Raw
$bat = Get-Content -LiteralPath $batPath -Raw

Assert-True ($ps1.Contains("ipa\__UNI__15CD4B6_0618111726.ipa.enc")) "PowerShell helper must write the expected encrypted IPA path"
Assert-True ($ps1.Contains("Read-Host") -and $ps1.Contains("-AsSecureString")) "PowerShell helper must prompt securely for IPA_DECRYPT_PASSWORD"
Assert-True ($ps1.Contains("scripts\encrypt_ipa.rb")) "PowerShell helper must call the repository encryption script"
Assert-True ($ps1.Contains("git commit")) "PowerShell helper must commit the encrypted IPA update"
Assert-True ($ps1.Contains("git push origin main")) "PowerShell helper must push main to GitHub"
Assert-True ($ps1.Contains("git status --porcelain")) "PowerShell helper must inspect repository state before committing"
Assert-True ($bat.Contains("upload-new-ipa.ps1")) "Batch launcher must call upload-new-ipa.ps1"

Write-Host "upload helper verification passed"
