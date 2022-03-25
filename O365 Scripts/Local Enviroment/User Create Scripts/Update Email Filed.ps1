Import-Module ActiveDirectory
Import-Csv E:\DOWNLOADS\create_ad_users\SharedCreation.csv | foreach {
Get-AdUser -Identity $_.SamAccountName | Set-ADUser -Description $_.title
}