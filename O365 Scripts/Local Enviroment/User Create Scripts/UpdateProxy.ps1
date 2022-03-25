Import-Module ActiveDirectory

#$USERS = Import-CSV c:\temp\MCNUsers.csv

Import-Csv "E:\DOWNLOADS\User Create Scripts\UserCreationsmtp1.csv" | Foreach {
    Write-Host "User:" $_.SamAccountName 
	Get-ADUser $_.Username | Set-ADUser -ADD @{proxyAddresses = ($_.SMTP2)}
}
