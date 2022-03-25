Import-Module ActiveDirectory
Get-ADUser -ResultPageSize 1000000 -SearchBase "DC=<Netbios>,DC=<Extension>" -Filter * | Export-csv <Full Path>