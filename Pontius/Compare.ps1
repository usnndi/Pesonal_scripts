$Directory_logs = Get-childitem -Name "C:\Users\cpontius\Documents\Compare1"
$Directory_logsPristine = Get-ChildItem -Name "C:\Users\cpontius\Documents\Compare2"

If($Directory_logs -eq $Directory_logsPristine){Write-Host "They are the same"}
If($Directory_logs -ne $Directory_logsPristine){Write-Host "They are the different"}