$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

##Enable Forwarding and Keep Mail
Set-Mailbox -Identity "Kathy Carpenter" -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "kcarpenter@cb-hb.com" 

##Enable Forwarding and do not keep mail
Set-Mailbox -Identity mmontalbo@cbipartner.com -ForwardingSMTPAddress mmontalbo@allcovered.com

##Remove Forwarding
Set-Mailbox -Identity "Kathy Carpenter" -DeliverToMailboxAndForward $false -ForwardingSMTPAddress $null

##Get Forwardin infomation
Get-Mailbox -ResultSize Unlimited | Select UserPrincipalName,ForwardingSMTPAddress,DeliverToMailboxandForward | Export-Csv 'C:\Users\jloveall\ASK\Project Services Group - Working Data\EVERSTREAM\O365 AD Migration\Export\05042018\SMTPForward.csv'
Get-Mailbox -Identity Mike* | FL

Remove-PSSession

Import-CSV 'C:\Users\jloveall\ASK\Project Services Group - Working Data\EVERSTREAM\O365 AD Migration\Export\05042018\SMTPForward.csv' | Foreach {
Set-Mailbox -Identity $_.Everstreamupn -DeliverToMailboxAndForward:([bool]([int]$_.DeliverToMailboxAndForwardnum)) -ForwardingSMTPAddress $_.ForwardingSmtpAddress > 'C:\Users\jloveall\ASK\Project Services Group - Working Data\EVERSTREAM\O365 AD Migration\Export\05042018\SMTPForwardInput.csv'}