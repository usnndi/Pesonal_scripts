# This script sets up the agreed upon options that ASK sets for every new Office 365 deployment.

# To use this script you will need to set the nessisary vairibles then run in in the 
# Windows Azure Active Directory Module for Windows PowerShell Module. You will also need
# the SharePoint Online Powershell module installed for this script to work. When running this
# script you will need to enter the client's Office 365 admin username and password when
# prompted for credentials.

#########################################

# Script Created By: Craig Pontius

# Script Last Updated By: Craig Pontius

# Script Last Modified Date: 10/6/2016

#########################################

# Set up the following Varibles. You will need to leave the quotation marks.
# Note that text will be case sensitive.

$AdminUser = "sbeltz@medallionmgmt.onmicrosoft.com" # Example: admin@contoso.onmicrosoft.com

# This is typiclly the part of the primary domain name before the .onmicrosoft.com part.
# For example, the tenant name for contoso.onmicrsoft.com would be contoso.
$TenantName = "medallionmgmt"

#########################################

# Set built in varibles:
$UserCredential = Get-Credential

#########################################

# Import nessisary modules:
Write-Host "Import SharePoint Module" 
Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell'

#########################################

#Connect to Office 365:
Write-Host "Connect to Office 365" 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
connect-msolservice -credential $UserCredential

#########################################
# This section runs the nessisary commands for the initial Office 365 setup.

# Set licensed users to have their UPN's changed via Directory Sync:
Write-Host "Enable UPN Synchronization" 
Set-MsolDirSyncFeature -Feature SynchronizeUpnForManagedUsers -Enable $True

# Setup Application Impersonation for the admin user.
Write-Host "Give admin user impersonation rights" 
Enable-OrganizationCustomization
New-ManagementRoleAssignment -Role ApplicationImpersonation -User $AdminUser

# Enable the creation of the Shared with Everyone folder in OneDrive for Business.
Write-Host "Setup Shared with Everyone Folder"
Connect-SPOService -Url https://$TenantName-admin.sharepoint.com -credential $UserCredential
Set-SPOTenant –SharingCapability Disabled –ProvisionSharedWithEveryoneFolder $true

#########################################

# End remote PowerShell session.
Remove-PSSession $Session