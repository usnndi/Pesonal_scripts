Connect-ExchangeOnline

Import-Csv C:\Temp\_Working\ExportData.csv | Foreach {
Start-ManagedFolderAssistant -Identity $_.User
}
$user = Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Foreach {
Start-ManagedFolderAssistant -Identity $user
}

Start-Transcript -Path C:\Temp\_Working\MBCSize.txt
Import-Csv C:\Temp\_Working\MBC.csv | Foreach {
Write-Host $_.User
Get-Mailbox -Identity $_.User | FL
}
Stop-Transcript