#Removing Orphaned Synced Users/Groups
Connect-MsolService
Remove-MsolUser -UserPrincipalName Amy.Richter-Perkins8423@cbremartin1.onmicrosoft.com 