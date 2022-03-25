$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Set-MailboxSearch "New" -InPlaceHoldEnabled $false
Remove-MailboxSearch "New"
#Remove-PSSession $Session