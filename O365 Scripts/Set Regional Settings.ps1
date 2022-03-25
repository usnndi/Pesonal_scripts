$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

get-mailbox | Set-MailboxRegionalConfiguration -Language 1033 -TimeZone "Eastern Standard Time" -WhatIf