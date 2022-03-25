Connect-EXOPSSession
Get-OrganizationConfig | ft name, *OAuth*
Set-OrganizationConfig -OAuth2ClientProfileEnabled:$true
Get-OrganizationConfig | ft name, *OAuth*
Remove-PSSession $session