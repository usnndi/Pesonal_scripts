######## Add Shared Mailboxes to O365 Mailbox from CSV input ###########

## Setup MSOnline Management Session
$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session

## Setup Variables

$csv = Import-CSV :./DentcoSharedMailboxes.csv


## Process Aliases

foreach ($line in $csv) {

if ($line.UserName -ne $line.DisplayName -ne $line.Alias) {

Write-Host "Adding alias" $line.Displayname " mailbox " $line.UserName -ForegroundColor Yellow -BackgroundColor Black


New-Mailbox -Name $line.DisplayName -Alias $line.Alias -Shared -PrimarySmtpAddress $line.UserName}

}

}
Remove-PSSession $Session