# 🌌 Galaxy Windows Terminal & PowerShell Config

My custom Windows Terminal and PowerShell styling with a Deep Space / Galaxy theme, custom system stats display (Neofetch-style), and a clean Arch-style prompt.

## 🚀 Features
- **Galaxy Color Scheme**: Custom vibrant theme with deep violet background and neon purple/cyan highlights.
- **Acrylic Transparency**: 70% opacity with blur effect.
- **Neofetch Welcome Screen**: Custom planet ASCII art displayed next to real-time system stats (CPU, RAM, Uptime) when launching PowerShell.
- **Arch-style Prompt**: Displays `username@hostname`, full current directory path, current time `[HH:mm:ss]`, and a green prompt arrow `❯` on a new line.

---

## 🛠️ File Structure
1. **`settings.json`**: Windows Terminal settings containing keybindings, profile commands, and the "Galaxy" scheme.
2. **`Microsoft.PowerShell_profile.ps1`**: PowerShell startup script that loads statistics, displays the ASCII art, and styles the prompt.
3. **`galaxy_ascii.txt`**: The planet ASCII art loaded by the profile.

---

## ⚙️ Installation / Restoration

If you ever need to restore this config on a new computer:

### 1. Copy the files to their targets:

Run the following commands in PowerShell to copy the files to their respective configuration directories:

```powershell
# Create target folders if they do not exist
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\WindowsPowerShell" -Force
New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -Force

# Copy configuration files
Copy-Item -Path ".\settings.json" -Destination "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
Copy-Item -Path ".\Microsoft.PowerShell_profile.ps1" -Destination "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force
Copy-Item -Path ".\galaxy_ascii.txt" -Destination "$env:USERPROFILE\Documents\WindowsPowerShell\galaxy_ascii.txt" -Force
```

### 2. Restart Windows Terminal
Simply open a new PowerShell tab, and the theme, transparency, stats, and prompt will immediately load!
