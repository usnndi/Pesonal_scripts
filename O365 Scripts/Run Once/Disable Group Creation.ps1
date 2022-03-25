$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Set-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default -GroupCreationEnabled $false

Get-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default

Remove-PSSession $Session