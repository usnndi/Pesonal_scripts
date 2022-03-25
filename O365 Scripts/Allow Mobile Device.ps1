# Connects to Office 365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

# Fill in the Users email address to allow.
$user = "amya@abgmi.com"
# Gets 
$mdm = Get-MobileDevice -Mailbox $user | Select -ExpandProperty DeviceID
#Write-Output $mdm

foreach ($mdm in $mdm) {
Set-CASMailbox -Identity $user -ActiveSyncAllowedDeviceIDs $mdm
Write-Output $mdm
}


Select-String

#Get-CASMailbox amya@abgmi.com | Select 
#Set-CASMailbox -Identity amya@abgmi.com -ActiveSyncAllowedDeviceIDs "SEC1705CCA61DE5A", "SEC29F1A3124ACCF", "androidc932919445", "c78db7a12ee6c595aef2c9a1257ff3ed", "SEC25847E8016C17", "ApplDMPK6WU5F185"
#Set-CASMailbox -Identity RRIKER@abgmi.com -ActiveSyncAllowedDeviceIDs "3AQ7UL83UH5NJ2O5774QFVR3HO", "5A11923BEE33F685"
#Set-CASMailbox -Identity larryr@abgmi.com -ActiveSyncAllowedDeviceIDs "C2219BC5596A0E4B"
Remove-PSSession $Session