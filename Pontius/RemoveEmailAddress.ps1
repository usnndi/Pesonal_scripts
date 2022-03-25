Import-Csv C:\Temp\MedallionAppRiverRemoveEmail.csv | Foreach {
Write-Host "User:" $_.Identity
Set-Mailbox $_.Identity -EmailAddresses @{Remove=$_.Email}
}