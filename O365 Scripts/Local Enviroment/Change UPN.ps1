Import-Module ActiveDirectory
$oldSuffix = "<Old Domain Name>"
$newSuffix = "<Alternate UPN>"
$ou = "DC=bobenal,DC=local"
$server = "<DC>"
Get-ADUser -SearchBase $ou -filter * | ForEach-Object {
$newUpn = $_.UserPrincipalName.Replace($oldSuffix,$newSuffix)
$_ | Set-ADUser -server $server -UserPrincipalName $newUpn
}