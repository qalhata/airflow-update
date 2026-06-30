[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = ".\airflow.cfg",

    [Parameter(Mandatory = $false)]
    [string]$OldValue = "560S",

    [Parameter(Mandatory = $false)]
    [string]$NewValue = "560s",

    [switch]$WhatIf
)

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Airflow config file not found: $ConfigPath"
}

$content = Get-Content -LiteralPath $ConfigPath -Raw
$matches = [regex]::Matches($content, [regex]::Escape($OldValue)).Count

if ($matches -eq 0) {
    Write-Host "No '$OldValue' values found in $ConfigPath. No changes made."
    exit 0
}

$updatedContent = $content.Replace($OldValue, $NewValue)

if ($WhatIf) {
    Write-Host "[WhatIf] Would replace $matches occurrence(s) of '$OldValue' with '$NewValue' in $ConfigPath."
    exit 0
}

$backupPath = "$ConfigPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item -LiteralPath $ConfigPath -Destination $backupPath -Force

Set-Content -LiteralPath $ConfigPath -Value $updatedContent -NoNewline
Write-Host "Updated $ConfigPath and created backup at $backupPath."
Write-Host "Replaced $matches occurrence(s) of '$OldValue' with '$NewValue'."
