Param(
$username
)
$365User="$username@hrc-engr.com"
$guid=(get-ADUser $username).Objectguid
$immutableID=[system.convert]::ToBase64String($guid.tobytearray())
Set-MsolUser -UserPrincipalName "$365User" -ImmutableId $immutableID 