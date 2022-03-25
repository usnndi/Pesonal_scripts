Import-Module ActiveDirectory

#$USERS = Import-CSV c:\temp\MCNUsers.csv

Import-Csv C:\Temp\import_create_ad_users.csv | Foreach {
    Write-Host "User:" $_.SamAccountName 
	Get-ADUser $_.SamAccountName | Set-ADUser -Add @{proxyAddresses = ($_.PriMail)}
    Get-ADUser $_.SamAccountName | Set-ADUser -Add @{proxyAddresses = ($_.SIP)}
	Get-ADUser $_.SamAccountName | Set-ADUser -Add @{proxyAddresses = ($_.SecMail)}
}