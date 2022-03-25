Get-ADGroupMember -Identity "O365-AAD Sync Users" | 
   Where-Object {$_.objectClass -eq 'user' } |
   Get-ADUser -Properties userPrincipalName | foreach {
   Set-ADUser $_ -UserPrincipalName (“{0}@{1}” -f $_.userPrincipalName.Split(“@”)[0],”everstream.net”)
   }