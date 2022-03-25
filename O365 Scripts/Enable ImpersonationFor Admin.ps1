$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Enable-OrganizationCustomization
New-ManagementRoleAssignment -Role ApplicationImpersonation -User askadmin@northstarcooperative.com
#Remove-PSSession $Session