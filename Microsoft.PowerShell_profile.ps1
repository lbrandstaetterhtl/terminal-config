# Clear screen first to keep it clean
Clear-Host

# Set console encoding to UTF-8 to support Unicode symbols
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Load ASCII Art
$asciiPath = "$env:USERPROFILE\Documents\WindowsPowerShell\galaxy_ascii.txt"
if (Test-Path $asciiPath) {
    $asciiLines = Get-Content $asciiPath
} else {
    $asciiLines = @()
}

# Get system stats
try {
    $osMem = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $totalMemGB = [Math]::Round($osMem.TotalVisibleMemorySize / 1024 / 1024, 1)
    $freeMemGB = [Math]::Round($osMem.FreePhysicalMemory / 1024 / 1024, 1)
    $usedMemGB = [Math]::Round($totalMemGB - $freeMemGB, 1)
    $memPercent = [Math]::Round(($usedMemGB / $totalMemGB) * 100)
} catch {
    $totalMemGB = "N/A"
    $usedMemGB = "N/A"
    $memPercent = "N/A"
}

try {
    $cpu = (Get-ItemProperty 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0' -ErrorAction SilentlyContinue).ProcessorNameString.Trim()
} catch {
    $cpu = "Unknown CPU"
}

try {
    $os = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).ProductName
    if ($os -like "*Windows 10*") {
        if ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild -ge 22000) {
            $os = $os -replace "10", "11"
        }
    }
} catch {
    $os = "Windows"
}

$uptimeSpan = [TimeSpan]::FromMilliseconds([Environment]::TickCount)
$uptime = "{0}d {1}h {2}m" -f $uptimeSpan.Days, $uptimeSpan.Hours, $uptimeSpan.Minutes

# Prepare Stats Lines
$stats = @(
    @{ Text = "brand@galaxy"; Color = "Magenta" },
    @{ Text = "------------"; Color = "DarkGray" },
    @{ Text = "OS:      $os"; Color = "White" },
    @{ Text = "CPU:     $cpu"; Color = "White" },
    @{ Text = "RAM:     $usedMemGB GB / $totalMemGB GB ($memPercent%)"; Color = "White" },
    @{ Text = "Uptime:  $uptime"; Color = "White" },
    @{ Text = "Shell:   PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"; Color = "White" },
    @{ Text = "Theme:   Galaxy"; Color = "White" }
)

# Print loop
$statsStartIndex = 5 # Start displaying stats at line 6 of ASCII art (0-indexed 5)
for ($i = 0; $i -lt $asciiLines.Count; $i++) {
    # Determine ASCII line color (gradient from Green to DarkGreen to Cyan)
    $asciiColor = "Green"
    if ($i -ge 6) { $asciiColor = "DarkGreen" }
    if ($i -ge 13) { $asciiColor = "Cyan" }
    
    # Print ASCII line padded to 55 chars
    $asciiLine = $asciiLines[$i].PadRight(55)
    Write-Host -NoNewline $asciiLine -ForegroundColor $asciiColor
    
    # Print stat if available
    $statIndex = $i - $statsStartIndex
    if ($statIndex -ge 0 -and $statIndex -lt $stats.Count) {
        $stat = $stats[$statIndex]
        Write-Host $stat.Text -ForegroundColor $stat.Color
    } else {
        Write-Host "" # Newline
    }
}
Write-Host ""

# Define prompt function
function prompt {
    $loc = $executionContext.SessionState.Path.CurrentLocation.Path
    
    # Get current time
    $time = Get-Date -Format "HH:mm:ss"
    
    # brand@galaxy in Magenta
    Write-Host -NoNewline "brand@galaxy " -ForegroundColor Magenta
    
    # path in Cyan
    Write-Host -NoNewline $loc -ForegroundColor Cyan
    
    # time in Gray
    Write-Host -NoNewline " [$time]" -ForegroundColor DarkGray
    
    # arrow in Green (using Unicode code point to bypass encoding errors)
    Write-Host -NoNewline "`n$([char]0x276f) " -ForegroundColor Green
    
    return " "
}
