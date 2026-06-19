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

If you want to install this configuration on a new PC:

1. Clone or download this repository.
2. Open PowerShell in the repository folder.
3. Run the installation script:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   .\install.ps1
   ```
4. Restart Windows Terminal!
