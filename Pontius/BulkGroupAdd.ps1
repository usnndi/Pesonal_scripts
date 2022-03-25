$Group = "Azure AD Sync"
Import-Module ActiveDirectory
Import-Csv C:\Temp\MPCUsers.csv | Foreach {
Write-Host "User: $_.SamAccountName"
Add-ADGroupMember $Group $_.SamAccountName
}