Import-Csv C:\Temp\MedallionO365UserCange.csv | Foreach {
Write-Host "User:" $_.CurrentUPN
Set-MsolUserPrincipalName -userPrincipalName $_.CurrentUPN -NewUserPrincipalName $_.NewUPN
}