$adminUPN="ASKAdmin@linnproducts.onmicrosoft.com"
$orgName="linnproducts"
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential
## Script to list out all the sites in your tenant including the personal sites or ODBs
Get-SPOSite -IncludePersonalSite $true | select url, Owner | Export-Csv -Path “C:\Temp\SPOSites.csv” -Delimiter “,”
## Sameple script to change the site collection administrator for the ODB sites. You need to create a CSV file with url and Owner columns. Owner would be the account name of the new owner.
Import-CSV C:\Temp\ChangeODBAdmin.csv | foreach-object { Set-SPOSite -Identity $_.Url -Owner $_.Owner} 