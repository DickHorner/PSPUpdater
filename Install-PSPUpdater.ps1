[CmdletBinding()]
param(
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$moduleName = 'PSPUpdater'
$sourcePath = Join-Path $PSScriptRoot $moduleName
$manifestPath = Join-Path $sourcePath "$moduleName.psd1"

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Manifest nicht gefunden: $manifestPath"
}

$documentsPath = [Environment]::GetFolderPath('MyDocuments')
$moduleRoot = Join-Path $documentsPath 'PowerShell\Modules'
$destinationPath = Join-Path $moduleRoot $moduleName

if (-not (Test-Path -LiteralPath $moduleRoot)) {
    $null = New-Item -Path $moduleRoot -ItemType Directory -Force
}

if (Test-Path -LiteralPath $destinationPath) {
    if (-not $Force) {
        throw "Ziel '$destinationPath' existiert bereits. Nochmal mit -Force ausfuehren, um zu ueberschreiben."
    }

    Remove-Item -LiteralPath $destinationPath -Recurse -Force
}

Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Recurse -Force
Import-Module (Join-Path $destinationPath "$moduleName.psd1") -Force

$command = Get-Command PSPU -ErrorAction Stop

Write-Host ''
Write-Host "PSPUpdater wurde installiert nach:" -ForegroundColor Green
Write-Host $destinationPath
Write-Host ''
Write-Host "Befehl verfuegbar als: $($command.Name)" -ForegroundColor Green
Write-Host 'Du kannst jetzt direkt `PSPU` ausfuehren.'
