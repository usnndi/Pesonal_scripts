$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

connect-msolservice -credential $UserCredential
Get-MsolUser –ReturnDeletedUsers | For-Each {
Remove-MsolUser –RemoveFromRecycleBin –Force
}
#Remove-Msoluser -UserPrincipalName chage -RemoveFromRecyclebin -Force

#Remove-PSSession $Session
Get-MsolUser -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin -Force