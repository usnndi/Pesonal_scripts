######## Add Alias to O365 Mailbox from CSV input ###########

## Setup MSOnline Management Session
$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session


## Setup Variables

$csv = Import-CSV :./Dentco-Aliases.csv


## Process Aliases

foreach ($line in $csv) {

if ($line.PrimaryEmailAddress -ne $line.SMTPAddress) {

Write-Host "Adding alias" $line.SMTPAddress " to mailbox " $line.PrimaryEmailAddress -ForegroundColor Yellow -BackgroundColor Black


Set-Mailbox -Identity $line.PrimaryEmailAddress -EmailAddresses @{add=$line.SMTPAddress}

}

}
Remove-PSSession $Session