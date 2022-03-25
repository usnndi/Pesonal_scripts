Import-Module ActiveDirectory
Get-ADUser -SearchBase "OU=Users,OU=Wieland,DC=ad,DC=wielandbuilds,DC=com” -Filter * | Export-Csv E:\DOWNLOADS\create_ad_users\Export.csv