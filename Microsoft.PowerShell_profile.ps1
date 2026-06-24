# Clear screen first to keep it clean
Clear-Host

# Set console encoding to UTF-8 to support Unicode symbols
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8

$hostLabel = "$env:USERNAME@$env:COMPUTERNAME"

# ── Theme configuration ───────────────────────────────────────────────────────
# To add a new theme: create <schemename_lowercase>_ascii.txt and add an entry below.
# Palette:    3 PowerShell color names [top, middle, bottom]
# ColorBands: 2 line numbers where the color transitions happen
$themeConfig = @{
    "Galaxy" = @{
        AsciiFile  = "galaxy_ascii.txt"
        Palette    = @("Green", "DarkGreen", "Cyan")
        ColorBands = @(6, 13)
    }
    "Arcane" = @{
        AsciiFile  = "arcane_ascii.txt"
        Palette    = @("Gray", "White", "Yellow")
        ColorBands = @(4, 14)
    }
}
$defaultTheme  = "Galaxy"
$statsStartRow = 5  # ASCII art row at which stats start appearing (0-indexed)

# ── Detect current Windows Terminal color scheme ──────────────────────────────
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$currentScheme  = $defaultTheme
try {
    $wtSettings = Get-Content $wtSettingsPath -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    if ($wtSettings.profiles.defaults.colorScheme) {
        $currentScheme = $wtSettings.profiles.defaults.colorScheme
    }
} catch {}

# ── Select active theme config (falls back to default) ───────────────────────
$theme = if ($themeConfig.ContainsKey($currentScheme)) { $themeConfig[$currentScheme] } else { $themeConfig[$defaultTheme] }

# ── Load ASCII art ────────────────────────────────────────────────────────────
$psDir      = "$env:USERPROFILE\Documents\WindowsPowerShell"
$asciiPath  = "$psDir\$($theme.AsciiFile)"
$asciiLines = if (Test-Path $asciiPath) { Get-Content $asciiPath } else { @() }

# Auto-calculate column width from the longest line in the ASCII file
$asciiWidth = if ($asciiLines.Count -gt 0) {
    [int]($asciiLines | Measure-Object -Property Length -Maximum).Maximum + 2
} else { 55 }

# ── Gather system stats ───────────────────────────────────────────────────────
try {
    $osMem      = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $totalMemGB = [Math]::Round($osMem.TotalVisibleMemorySize / 1024 / 1024, 1)
    $freeMemGB  = [Math]::Round($osMem.FreePhysicalMemory  / 1024 / 1024, 1)
    $usedMemGB  = [Math]::Round($totalMemGB - $freeMemGB, 1)
    $memPercent = [Math]::Round(($usedMemGB / $totalMemGB) * 100)
} catch { $totalMemGB = $usedMemGB = $memPercent = "N/A" }

try {
    $cpu = (Get-ItemProperty 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0' -ErrorAction SilentlyContinue).ProcessorNameString.Trim()
} catch { $cpu = "Unknown CPU" }

try {
    $os = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).ProductName
    if ($os -like "*Windows 10*" -and
        (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild -ge 22000) {
        $os = $os -replace "10", "11"
    }
} catch { $os = "Windows" }

$uptimeSpan = [TimeSpan]::FromMilliseconds([Environment]::TickCount)
$uptime     = "{0}d {1}h {2}m" -f $uptimeSpan.Days, $uptimeSpan.Hours, $uptimeSpan.Minutes

# ── Build stats list ──────────────────────────────────────────────────────────
$stats = @(
    @{ Text = $hostLabel;                                                                                    Color = "Magenta" }
    @{ Text = "-" * $hostLabel.Length;                                                                       Color = "DarkGray" }
    @{ Text = "OS:      $os";                                                                                Color = "White" }
    @{ Text = "CPU:     $cpu";                                                                               Color = "White" }
    @{ Text = "RAM:     $usedMemGB GB / $totalMemGB GB ($memPercent%)";                                      Color = "White" }
    @{ Text = "Uptime:  $uptime";                                                                            Color = "White" }
    @{ Text = "Shell:   PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)";   Color = "White" }
    @{ Text = "Theme:   $currentScheme";                                                                     Color = "White" }
)

# ── Render ASCII art + stats side by side ─────────────────────────────────────
$palette    = $theme.Palette
$colorBands = $theme.ColorBands

for ($i = 0; $i -lt $asciiLines.Count; $i++) {
    # Pick color from palette based on current line
    $asciiColor = $palette[0]
    if ($i -ge $colorBands[0]) { $asciiColor = $palette[1] }
    if ($i -ge $colorBands[1]) { $asciiColor = $palette[2] }

    Write-Host -NoNewline $asciiLines[$i].PadRight($asciiWidth) -ForegroundColor $asciiColor

    $statIndex = $i - $statsStartRow
    if ($statIndex -ge 0 -and $statIndex -lt $stats.Count) {
        Write-Host $stats[$statIndex].Text -ForegroundColor $stats[$statIndex].Color
    } else {
        Write-Host ""
    }
}
Write-Host ""

# ── Prompt ────────────────────────────────────────────────────────────────────
function prompt {
    $loc  = $executionContext.SessionState.Path.CurrentLocation.Path
    $time = Get-Date -Format "HH:mm:ss"
    Write-Host -NoNewline "$hostLabel " -ForegroundColor Magenta
    Write-Host -NoNewline $loc          -ForegroundColor Cyan
    Write-Host -NoNewline " [$time]"    -ForegroundColor DarkGray
    Write-Host -NoNewline "`n$([char]0x276f) " -ForegroundColor Green
    return " "
}

# ── Theme switcher ────────────────────────────────────────────────────────────
# Reads available schemes live from Windows Terminal settings — no hardcoded list needed.
function Set-Theme {
    param([Parameter(Mandatory, Position = 0)][string]$Name)

    $path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    try {
        $json      = Get-Content $path -Raw | ConvertFrom-Json
        $available = $json.schemes | ForEach-Object { $_.name }

        if ($Name -notin $available) {
            Write-Host "❌ '$Name' nicht gefunden." -ForegroundColor Red
            Write-Host "   Verfügbar: $($available -join ' | ')" -ForegroundColor DarkGray
            return
        }

        $content = Get-Content $path -Raw
        $content  = $content -replace '("colorScheme"\s*:\s*)"[^"]*"', "`$1`"$Name`""
        Set-Content $path $content -Encoding UTF8 -NoNewline
        Write-Host "✅ Theme '$Name' aktiviert! Öffne ein neues Terminal-Fenster." -ForegroundColor Green
    } catch {
        Write-Host "❌ Fehler: $_" -ForegroundColor Red
    }
}

# ── Load aliases from aliases.json ───────────────────────────────────────────
# To add/remove aliases, edit aliases.json — no profile changes needed.
$aliasesPath = "$psDir\aliases.json"
if (Test-Path $aliasesPath) {
    try {
        $aliasEntries = Get-Content $aliasesPath -Raw | ConvertFrom-Json
        foreach ($entry in $aliasEntries) {
            $resolvedValue = [System.Environment]::ExpandEnvironmentVariables($entry.Value)
            Set-Alias -Name $entry.Name -Value $resolvedValue -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Warning "aliases.json konnte nicht geladen werden: $_"
    }
}
