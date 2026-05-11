$stateFile = "$HOME\temp-setup\state.txt"
$initialState = @"
Debloat: False
Language: False
Chocolatey: False
Git: False
Github: False
PowerToys: False
Obsidian: False
VSCode: False
WSL: False
Browser: False
Theme: False
Power: False
Spotify: False
Dotnet: False
Docker: False
"@

###############################
# State file
###############################
if (!(Test-Path -Path $stateFile)) {
  Write-Host "State file not found, creating one under '$HOME\temp-setup\state.txt'..." -ForegroundColor Cyan
  New-Item -Path "$HOME\temp-setup" -ItemType directory -Force | Out-Null
  New-Item -Path "$HOME\temp-setup\state.txt" -ItemType file | Out-Null

  $initialState | Out-File -FilePath $stateFile -Append -Encoding utf8 -Force
  Write-Host "✔ State file created" -ForegroundColor Green
}

###############################
# English language locale
###############################
if (Select-String -Path $stateFile -Pattern "Language: False") {
  Write-Host "Setting system locale to en-US..." -ForegroundColor Cyan
  if (!((Get-UICulture).Name -eq "en-US")) {
    Install-Language en-US
    Set-WinUILanguageOverride -Language en-US
  }
  (Get-Content $stateFile) -replace "Language: False", "Language: True" | Set-Content $stateFile
  Write-Host "✔ System locale set to en-US" -ForegroundColor Green
}

###############################
# Chocolatey
###############################
if (Select-String -Path $stateFile -Pattern "Chocolatey: False") {
  if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  }
  if (Get-Command choco -ErrorAction SilentlyContinue) {
      (Get-Content $stateFile) -replace "Chocolatey: False", "Chocolatey: True" | Set-Content $stateFile
      choco -v
      Write-Host "✔ Chocolatey installed" -ForegroundColor Green
  }
}

###############################
# Git
###############################
if (Select-String -Path $stateFile -Pattern "Git: False") {
  if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing git..." -ForegroundColor Cyan
    choco install git -y  
  }
  if (Get-Command git -ErrorAction SilentlyContinue) {
    (Get-Content $stateFile) -replace "Git: False", "Git: True" | Set-Content $stateFile
    git -v
    git config --global user.email "char@novax.dk"
    git config --global user.name "Arensbak"
    Write-Host "✔ Git installed" -ForegroundColor Green
  }
}

###############################
# Debloat script
###############################
if (Select-String -Path $stateFile -Pattern "Debloat: False") {
  git clone git@github.com:Raphire/Win11Debloat.git $HOME\temp-setup\debloat
  .\$HOME\temp-setup\debloat\Win11Debloat.ps1
  (Get-Content $stateFile) -replace "Debloat: False", "Debloat: True" | Set-Content $stateFile
}

###############################
# Github CLI
###############################
if (Select-String -Path $stateFile -Pattern "Github: False") {
  if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing github cli..." -ForegroundColor Cyan
    choco install gh -y
  }

  if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh --version
    Write-Host "✔ Github CLI installed" -ForegroundColor Green
  }
  
  gh auth login
  (Get-Content $stateFile) -replace "Github: False", "Github: True" | Set-Content $stateFile
}

###############################
# PowerToys
###############################
if (Select-String -Path $stateFile -Pattern "PowerToys: False") {
  winget install PowerToys --source winget

  (Get-Content $stateFile) -replace "PowerToys: False", "PowerToys: True" | Set-Content $stateFile
}

###############################
# Theme
###############################
if (Select-String -Path $stateFile -Pattern "Theme: False") {
  $currentVersion = "HKCU:\Software\Microsoft\Windows\CurrentVersion"
  Set-ItemProperty -Path "$currentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
  Set-ItemProperty -Path "$currentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
  
  $accentBytes = [byte[]](
    255, 232,  69,   0,
    255, 215,   0,   0,
    255, 180,   0,   0,
    230, 160,   0,   0,
    200, 140,   0,   0,
    170, 120,   0,   0,
    140, 100,   0,   0,
      0,   0,   0,   0
  )
  Set-ItemProperty -Path "$currentVersion\Explorer\Accent" -Name "AccentPalette" -Value $accentBytes
  
  (Get-Content $stateFile) -replace "Theme: False", "Theme: True" | Set-Content $stateFile
}

###############################
# Obsidian & Notes
###############################
if (Select-String -Path $stateFile -Pattern "Obsidian: False") {
  choco install obsidian -y
  git clone git@github.com:carensbak/Notes.git $HOME\Notes

  (Get-Content $stateFile) -replace "Obsidian: False", "Obsidian: True" | Set-Content $stateFile
}

###############################
# Power options
###############################
if (Select-String -Path $stateFile -Pattern "Power: False") {
  powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 0 #These should prevent the PC from going into idle/sleep mode after X seconds, so we manually have to lock the PC
  powercfg /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 0

  (Get-Content $stateFile) -replace "Power: False", "Power: True" | Set-Content $stateFile
}

###############################
# Browser
###############################
if (Select-String -Path $stateFile -Pattern "Browser: False") {
  $headers = @{"Cache-Control"="no-cache"; "Pragma"="no-cache"}
  irm "https://raw.githubusercontent.com/carensbak/setup-windows/refs/heads/master/remove-edge.ps1" -Headers $headers | iex
  winget install brave

  (Get-Content $stateFile) -replace "Browser: False", "Browser: True" | Set-Content $stateFile
}

###############################
# WSL
###############################
if (Select-String -Path $stateFile -Pattern "WSL: False") {
  wsl --install Debian
  
  (Get-Content $stateFile) -replace "WSL: False", "WSL: True" | Set-Content $stateFile
}

###############################
# VSCode
###############################
if (Select-String -Path $stateFile -Pattern "VSCode: False") {
  # Install VSCode itself
  winget install vscode --Id Microsoft.VisualStudioCode

   # Install the VSCode plugins
  $pluginsList = irm "https://raw.githubusercontent.com/carensbak/setup-windows/refs/heads/master/vscode/plugins.txt"
  $pluginslist -split "`r?`n" | Where-Object { $_.Trim() } | ForEach-Object { 
    code --install-extension $_
  }

  # Copy over the settings
  $settingsContent = irm "https://raw.githubusercontent.com/carensbak/setup-windows/refs/heads/master/vscode/settings.json"
  $settingsPath = Join-Path $env:APPDATA "Code\User\settings.json"
  $settingsContent | Out-File -FilePath $settingsPath -Encoding utf8
  
  (Get-Content $stateFile) -replace "VSCode: False", "VSCode: True" | Set-Content $stateFile
}

###############################
# Spotify
###############################
if (Select-String -Path $stateFile -Pattern "Spotify: False") {
  winget install spotify --source msstore --accept-package-agreements
  
  (Get-Content $stateFile) -replace "Spotify: False", "Spotify: True" | Set-Content $stateFile
}

###############################
# Dotnet SDK & Runtime
###############################
if (Select-String -Path $stateFile -Pattern "Dotnet: False") {
  winget install Microsoft.DotNet.AspNetCore.10
  winget install Microsoft.DotNet.SDK.10
  
  (Get-Content $stateFile) -replace "Dotnet: False", "Dotnet: True" | Set-Content $stateFile
}

###############################
# Docker & Docker Desktop
###############################
if (Select-String -Path $stateFile -Pattern "Docker: False") {
  winget install -e --Id Docker.DockerDesktop
  
  (Get-Content $stateFile) -replace "Docker: False", "Docker: True" | Set-Content $stateFile
}
