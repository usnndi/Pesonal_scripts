Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://1sthousing-admin.sharepoint.com
Set-SPOTenant –SharingCapability Disabled –ProvisionSharedWithEveryoneFolder $true