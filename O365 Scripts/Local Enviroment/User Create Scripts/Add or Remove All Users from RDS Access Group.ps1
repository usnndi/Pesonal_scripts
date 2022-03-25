Import-module ActiveDirectory

#Get-ADGroupMember -Identity Wieland-Azure-RDS-Users | Export-Csv C:\Users\Setup\Desktop\Wieland-Azure-RDS-Users.csv

## Remove Users from Group
#Import-CSV "C:\Users\Setup\Desktop\Wieland-Azure-RDS-Users.csv" | % { 
#Remove-ADGroupMember -Identity Wieland-Azure-RDS-Users -Member $_.SamAccountName 
#}

## Add Users Back to group
Import-CSV "C:\Users\Setup\Desktop\Wieland-Azure-RDS-Users.csv" | % { 
Add-ADGroupMember -Identity Wieland-Azure-RDS-Users -Member $_.SamAccountName 
}