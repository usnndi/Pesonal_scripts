$credential = Get-Credential
$session = New-CsOnlineSession -Credential $credential -Verbose
Import-PSSession $session
#Get-Module
#Get-Command -Module tmp_5astd3uh.m5v
#Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed
#Get-CsOAuthConfiguration

#Remove-PSSession $session


#This enables Skype for Business Modern Authentication
# You will need to connect to Skype for Business Online via Powershell https://docs.microsoft.com/en-us/SkypeForBusiness/set-up-your-computer-for-windows-powershell/download-and-install-the-skype-for-business-online-connector
$credential = Get-Credential
$session = New-CsOnlineSession -Credential $credential -Verbose
Import-PSSession $session
Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed
Get-CsOAuthConfiguration
Remove-PSSession $session

#This enables Exchange Online Modern Authentication
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
Get-OrganizationConfig | select OAuth2ClientProfileEnabled
Remove-PSSession $session