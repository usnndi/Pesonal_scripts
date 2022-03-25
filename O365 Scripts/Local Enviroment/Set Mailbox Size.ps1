Connect-ExchangeOnline
Import-Csv -Path C:\Temp\Wieland.csv | ForEach-Object {
Set-Mailbox -Identity $_.ID -ProhibitSendQuota 99GB -ProhibitSendReceiveQuota 100GB -IssueWarningQuota 98GB
}