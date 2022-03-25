$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Setup AUditing Capability
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditEnabled $true
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -AuditOwner MailboxLogin,HardDelete

#Set Regional Location and Language
Get-Mailbox -ResultSize Unlimited | Set-MailboxRegionalConfiguration -Language 1033 -TimeZone "Eastern Standard Time"