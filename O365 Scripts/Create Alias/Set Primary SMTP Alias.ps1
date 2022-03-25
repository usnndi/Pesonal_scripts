######## Add Alias to O365 Mailbox from CSV input ###########

## Setup MSOnline Management Session
$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session


## Setup Variables

Import-CSV "C:\Users\jloveall\ASK\Project Services Group - Working Data\CENTRAL STAR\EMAIL & DOMAIN Consolidation\Working\Runfull.csv" | foreach {

$SMTP = "SMTP:" + $_.New

Write-Host "Adding alias" $SMTP " to mailbox " $line.Current -ForegroundColor Yellow -BackgroundColor Black

#Set-Mailbox -Identity $_.Current -EmailAddresses @{add=$_.New} -WhatIf

Set-Mailbox -Identity $_.Current -EmailAddresses $SMTP

}
#Remove-PSSession $Session