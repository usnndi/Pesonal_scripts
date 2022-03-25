Connect-ExchangeOnline
Connect-msolservice -credential $UserCredential
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
Remove-PSSession $Session

Import-Module MicrosoftTeams
Connect-MicrosoftTeams
Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed
Get-CsOAuthConfiguration
Disconnect-MicrosoftTeams