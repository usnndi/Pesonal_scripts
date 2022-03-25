Import-Csv C:\Temp\Bpremusrs.csv | ForEach-Object {
$User = $_.UPN
Get-Mailbox -Identity $User
Set-User clewis@csiadvantege.com -PermanentlyClearPreviousMailboxInfo -Force
}


Set-User mcalabrese@csiadvantage.com -PermanentlyClearPreviousMailboxInfo -Force
Set-User klee@csiadvantage.com -PermanentlyClearPreviousMailboxInfo -Force
#Set-User clewis@csiadvantage.com -PermanentlyClearPreviousMailboxInfo -Force

Get-Mailbox -Identity mcalabrese@csiadvantage.com
Connect-ExchangeOnline
