# Set UTF-8 encoding for nice console symbols
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host ""
Write-Host "🌌 Installing Galaxy Windows Terminal & PowerShell Config..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor DarkGray

# Get directory where install.ps1 is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir) { $scriptDir = $PSScriptRoot }
if (-not $scriptDir) { $scriptDir = "." }

# Targets
$wtTargetDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$psTargetDir = "$env:USERPROFILE\Documents\WindowsPowerShell"

# Create target directories
New-Item -ItemType Directory -Path $wtTargetDir -Force | Out-Null
New-Item -ItemType Directory -Path $psTargetDir -Force | Out-Null

# Helper function to copy with backup
function Copy-WithBackup ($file, $src, $dest) {
    $sourceFile = Join-Path $src $file
    $destFile = Join-Path $dest $file

    if (-not (Test-Path $sourceFile)) {
        Write-Host "❌ Error: Source file not found: $file" -ForegroundColor Red
        return
    }

    if (Test-Path $destFile) {
        $backupFile = $destFile + ".bak"
        Write-Host "💾 Backing up existing $file to $(Split-Path $backupFile -Leaf)..." -ForegroundColor Yellow
        Copy-Item -Path $destFile -Destination $backupFile -Force
    }

    Write-Host "🚀 Copying $file to target folder..." -ForegroundColor Gray
    Copy-Item -Path $sourceFile -Destination $destFile -Force
}

# Copy configurations
Copy-WithBackup "settings.json" $scriptDir $wtTargetDir
Copy-WithBackup "Microsoft.PowerShell_profile.ps1" $scriptDir $psTargetDir
Copy-WithBackup "galaxy_ascii.txt" $scriptDir $psTargetDir
Copy-WithBackup "arcane_ascii.txt" $scriptDir $psTargetDir
Copy-WithBackup "aliases.json" $scriptDir $psTargetDir

Write-Host "==========================================================" -ForegroundColor DarkGray
Write-Host "🎉 Installation successful!" -ForegroundColor Green
Write-Host "👉 Please restart Windows Terminal to apply the changes." -ForegroundColor Cyan
Write-Host ""
