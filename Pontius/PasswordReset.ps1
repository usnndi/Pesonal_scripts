Import-Csv C:\Temp\2SPPasswords.csv | Foreach {
Write-Host "User:" $_.SamAccountName 
Set-MsolUserPassword -userPrincipalName $_.SamAccountName –NewPassword $_.Password -ForceChangePassword $False
}