Import-Module ActiveDirectory
Import-Csv C:\Temp\O365Users.csv | Foreach {
Write-Host "User:" $_.Username
$ADGuid = (Get-ADUser -Identity $_.Username).ObjectGIUD
$immutableid = [System.Convert]::ToBase64String($ADGuid.tobytearray())
Set-MsolUser -UserPrincipalName $_.UPN -ImmutableId $immutableid
}