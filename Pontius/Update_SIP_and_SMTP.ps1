Import-Module ActiveDirectory

#$USERS = Import-CSV c:\temp\MCNUsers.csv

Import-Csv C:\ESB_ProxyAddress_Change.csv | Foreach {
    Write-Host "User:" $_.SamAccountName 
	Get-ADUser $_.SamAccountName | Set-ADUser -Remove @{proxyAddresses = ($_.SMTP)}
    Get-ADUser $_.SamAccountName | Set-ADUser -Add @{proxyAddresses = ($_.SIP)}
	Get-ADUser $_.SamAccountName | Set-ADUser -Add @{proxyAddresses = ($_.SMTP1)}
    Get-ADUser $_.SamAccountName | Set-ADUser -Add @{proxyAddresses = ($_.SMTP2)}
}