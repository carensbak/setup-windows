$stateFile = "$HOME\temp-setup\state.txt"
$initialState = @"
Language: False
Chocolatey: False
Git: False
Github: False
PowerToys: False
Obsidian: False
VSCode: False
WSL: False
Browser: False
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
  if (Get-Command choco -ErrorAction SilentlyContinue)) {
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
  if (Get-Command git -ErrorAction SilentlyContinue)) {
    (Get-Content $stateFile) -replace "Git: False", "Git: True" | Set-Content $stateFile
    git -v
    Write-Host "✔ Git installed" -ForegroundColor Green
  }
}

###############################
# Github CLI
###############################
if (Select-String -Path $stateFile -Pattern "Github: False") {
  if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing github cli..." -ForegroundColor Cyan
    choco install gh -y
  }

  if (Get-Command gh -ErrorAction SilentlyContinue)) {
    gh --version
    Write-Host "✔ Github CLI installed" -ForegroundColor Green
  }
  
  gh auth login
  (Get-Content $stateFile) -replace "Github: False", "Github: True" | Set-Content $stateFile
}

