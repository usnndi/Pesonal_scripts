Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell'
Connect-SPOService -Url https://ShiawasseePhysicians-admin.sharepoint.com -credential shiawasseephysicians@ShiawasseePhysicians.onmicrosoft.com
Set-SPOTenant –SharingCapability Disabled –ProvisionSharedWithEveryoneFolder $true