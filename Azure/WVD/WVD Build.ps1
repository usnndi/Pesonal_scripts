#All Created From Windows Virtual Desktop Documentation
start 'https://docs.microsoft.com/en-us/azure/virtual-desktop/'

#Install PowerShell modules
Install-Module -Name Microsoft.RDInfra.RDPowerShell
Import-Module -Name Microsoft.RDInfra.RDPowerShell

#Grant permissions to Windows Virtual Desktop
start 'https://login.microsoftonline.com/common/adminconsent?client_id=5a0aa725-4958-4b0c-80a9-34562e23f3b7&redirect_uri=https%3A%2F%2Frdweb.wvd.microsoft.com%2FRDWeb%2FConsentCallback'
start 'https://login.microsoftonline.com/common/adminconsent?client_id=fa4345a4-a730-4230-84a8-7d9651b86739&redirect_uri=https%3A%2F%2Frdweb.wvd.microsoft.com%2FRDWeb%2FConsentCallback'


# Setting Deployment context
$brokerurl = "https://rdbroker.wvd.microsoft.com"
$aadTenantId = "56385618-98a1-4d64-80c1-2a7fc23c8922"
$azureSubscriptionId = "21e0501c-ab64-4cc9-a795-cf6b33a4e1fc"
Add-RdsAccount -DeploymentUrl $brokerurl -

#Create a Windows Virtual Desktop tenant
New-RdsTenant -Name "ASKWVD" -FriendlyName "ASK WVD" -Description "WVD Pilot" -AadTenantId $aadTenantId -AzureSubscriptionId $azureSubscriptionId


#TenantGroupName         : Default Tenant Group
#AadTenantId             : 56385618-98a1-4d64-80c1-2a7fc23c8922
#TenantName              : ASKWVD
#Description             : WVD Pilot
#FriendlyName            : ASK WVD
#SsoAdfsAuthority        : 
#SsoClientId             : 
#SsoClientSecret         : 
#AzureSubscriptionId     : 21e0501c-ab64-4cc9-a795-cf6b33a4e1fc
#LogAnalyticsWorkspaceId : 
#LogAnalyticsPrimaryKey  : 

#Create a service principal in Azure Active Directory
Install-Module AzureAD
Import-Module AzureAD
$aadContext = Connect-AzureAD
$svcPrincipal = New-AzureADApplication -AvailableToOtherTenants $true -DisplayName "ASKWVD Svc Principal"
$svcPrincipalCreds = New-AzureADApplicationPasswordCredential -ObjectId $svcPrincipal.ObjectId

#View Credentials
$svcPrincipalCreds.Value
$aadContext.TenantId.Guid
$svcPrincipal.AppId

#$svcPrincipalCreds.Value
#Bh9WyaHb7/grfXv5mZHEz2hjtXoULjMH8clLw8B6H8Q=

#$aadContext.TenantId.Guid
#56385618-98a1-4d64-80c1-2a7fc23c8922

#$svcPrincipal.AppId
#5eee975c-b3a7-4d9f-b808-007b227f6c5e


#Create a role assignment in Windows Virtual Desktop
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
Get-RdsTenant

$myTenantName = "ASKWVD"
New-RdsRoleAssignment -RoleDefinitionName "RDS Owner" -ApplicationId $svcPrincipal.AppId -TenantName $myTenantName

#Sign in with the service principal
$creds = New-Object System.Management.Automation.PSCredential($svcPrincipal.AppId, (ConvertTo-SecureString $svcPrincipalCreds.Value -AsPlainText -Force))
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -Credential $creds -ServicePrincipal -AadTenantId $aadContext.TenantId.Guid

#Sign in to Azure Portal To Create 
start 'https://portal.azure.com/#create/rds.wvd-provision-host-poolpreview' 


start 'https://docs.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-azure-marketplace'

#Create a RemoteApp group
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

Get-RdsHostPool -TenantName ASKWVD
New-RdsAppGroup -HostPoolName "ASK-WVD-HOST-POOL" -Name "ASK-WVD-APP-POOL" -TenantName ASKWVD -Description "Initial App Pool"

#Get List of Install Start Menu Apps
Get-RdsStartMenuApp -AppGroupName "ASK-WVD-APP-POOL" -HostPoolName "ASK-WVD-HOST-POOL" -TenantName ASKWVD > C:\Temp\Apps.txt
start 'C:\Temp\Apps.txt'

#######Not Started Yet - 10/23/2019************************

# Publish Application From the Apps.txt Output
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
#Used to Publish each individual Application
New-RdsRemoteApp -AppGroupName ASK-WVD-APP-POOL -HostPoolName ASK-WVD-HOST-POOL -Name "Windows Media Player" -TenantName ASKWVD -AppAlias windowsmediaplayer -ShowInWebFeed
#Add Users to See Published App Group
Add-RdsAppGroupUser -AppGroupName ASK-WVD-APP-POOL -HostPoolName ASK-WVD-HOST-POOL -TenantName ASKWVD -UserPrincipalName "wvdadmin@justaskwvd.net"

#Create a host pool to validate service updates. Optional, will increase cost by having additional hosts running.
start 'https://docs.microsoft.com/en-us/azure/virtual-desktop/create-validation-host-pool'
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

Set-RdsHostPool -Name ASK-WVD-HOST-POOL -TenantName ASKWVVD -ValidationEnv $true

