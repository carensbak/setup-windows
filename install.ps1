###############################
# State file
###############################
$stateFile = "$HOME\temp-setup\state.txt"
if (!(Test-Path -Path $stateFile)) {
  Write-Host "State file not found, creating one under '$HOME\temp-setup\state.txt'..." -ForegroundColor Cyan
  New-Item -Path "$HOME\temp-setup" -ItemType directory -Force | Out-Null
  New-Item -Path "$HOME\temp-setup\state.txt" -ItemType file | Out-Null

  "Language: False" | Out-File -FilePath $stateFile -Append -Encoding utf8 -Force
  Write-Host "✔ State file created" -ForegroundColor Green
}

###############################
# English language locale
###############################
if (Select-String -Path $stateFile -Pattern "Language: Fals") {
  Write-Host "Setting system locale to en-US..." -ForegroundColor Cyan
  if (!((Get-UICulture).Name -eq "en-US")) {
    Install-Language en-US
    Set-WinUserLanguageList -LanguageList en-US -Force
  }
  (Get-Content $stateFile) -replace "Language: False", "Language: True" | Set-Content $stateFile
  Write-Host "✔ System locale set to en-US" -ForegroundColor Green
}
