$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session

Get-OrganizationConfig | fl *DefaultPublicFolder*

 

Set-OrganizationConfig -DefaultPublicFolderProhibitPostQuota 10737418240

#10 GB

Set-OrganizationConfig -DefaultPublicFolderIssueWarningQuota 9663676416