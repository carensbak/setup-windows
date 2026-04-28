###############################
# State file
###############################
$stateFile = "$HOME\temp-setup\state.txt"
if (!(Test-Path -Path $stateFile)) {
  echo "State file not found, creating one under '$HOME\temp-setup\state.txt'..." -ForegroundColor Cyan
  New-Item -Path "$HOME\temp" -ItemType directory -Force
  New-Item -Path "$HOME\temp\state.txt" -ItemType file

  "Language: False" >> "$HOME\temp\state.txt"
  echo "✔ State file created" -ForegoundColor Green
}

###############################
# English language locale
###############################
if (Select-String -Path $stateFile -Pattern "Language: False") {
  echo "Setting system locale to en-US..." -ForegroundColor Cyan
  if (!(Get-UICulture -eq "en-US") {
    Install-Language en-US
    Set-WinUserLanguageList -LanguageList en-US -Force
  }
  (Get-Content $stateFile) -replace "Language: False", "Language: True" | Set-Content $stateFile
  echo "✔ System locale set to en-US" -ForegoundColor Green
}
