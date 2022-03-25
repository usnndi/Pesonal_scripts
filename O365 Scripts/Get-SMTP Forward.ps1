$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Get-Mailbox -ResultSize Unlimited | select UserPrincipalName,Identity,ForwardingSMTPAddress,DeliverToMailboxandForward | Export-Csv 'C:\Users\jloveall\ASK\Project Services Group - Working Data\EVERSTREAM\O365 AD Migration\Neo Migraation\SMTPForward.csv'