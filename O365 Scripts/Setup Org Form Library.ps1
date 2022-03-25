$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

New-PublicFolder -Path "\NON_IPM_SUBTREE\EFORMS REGISTRY" -Name "Organizational Forms Library"
	
Set-PublicFolder "\NON_IPM_SUBTREE\EFORMS REGISTRY\Organizational Forms Library" -EformsLocaleID en-US

Get-PublicFolder -Identity "\NON_IPM_SUBTREE\EFORMS REGISTRY\Organizational Forms Library" -Recurse | Format-List Name
	
Add-PublicFolderClientPermission -identity "\NON_IPM_SUBTREE\EFORMS REGISTRY\Organizational Forms Library" -user jloveall@justask.net -AccessRights Owner

Get-PublicFolderClientPermission "\NON_IPM_SUBTREE\EFORMS REGISTRY\Organizational Forms Library"

Add-PublicFolderClientPermission -identity "\NON_IPM_SUBTREE\EFORMS REGISTRY\Organizational Forms Library" -user codetwo@justask.net -AccessRights ReadItems

Add-PublicFolderClientPermission -identity "\NON_IPM_SUBTREE\EFORMS REGISTRY\Organizational Forms Library" -user jloveall@justask.net -AccessRights CreateItems