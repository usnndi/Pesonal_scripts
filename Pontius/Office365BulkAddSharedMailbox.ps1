#########################################

# Set built in varibles:
$UserCredential = Get-Credential

#########################################

#Connect to Office 365:
Write-Host "Connect to Office 365" 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
connect-msolservice -credential $UserCredential

#########################################
Import-Csv C:\Temp\O365SharedMailbox.csv | Foreach {
Write-host "Mailbox: $_.DisplayName"
New-Mailbox -Shared -DisplayName $_.DisplayName -Name $_.Name -Alias $_.Name -PrimarySmtpAddress $_.EmailAddress
}