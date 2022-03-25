#EX2010 Impersonation
New-ManagementRoleAssignment -Name: impersonationAssignmentName -Role: ApplicationImpersonation -RecipientOrganizationalUnitScope "darco.asp/Hosting Reliance 2011/MMA/Users" -user: cookdane
New-ManagementRoleAssignment –Name:impersonationAssignmentName –Role:ApplicationImpersonation –User:cookdane

#EX2007 Impersonaation
Get-ExchangeServer | where {$_.IsClientAccessServer -eq $TRUE} | ForEach-Object {Add-ADPermission -Identity $_.distinguishedname -User (Get-User -Identity cookdane | select-object).identity -extendedRight ms-Exch-EPI-Impersonation}
Get-MailboxDatabase | ForEach-Object {Add-ADPermission -Identity $_.DistinguishedName -User cookdane -ExtendedRights ms-Exch-EPI-May-Impersonate}