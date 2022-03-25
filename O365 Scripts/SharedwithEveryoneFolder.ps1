Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell'
Connect-SPOService -Url https://cbremartin1-admin.sharepoint.com -credential cbremartin@cbremartin1.onmicrosoft.com
Set-SPOTenant –SharingCapability Disabled –ProvisionSharedWithEveryoneFolder $true