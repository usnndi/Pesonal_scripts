Import-Csv C:\Temp\MaplesO365AddEmail.csv | Foreach {
Write-Host "User:" $_.Identity
Set-Mailbox $_.Identity -EmailAddresses @{add=$_.Email}
Set-Mailbox  $_.Identity -EmailAddress $_.Email
}