cd\
cd C:\Temp\PSModules
Import-Module .\AzureRm.AcceleratedNIC.CoreHelper.psm1
Import-Module .\AzureRm.AcceleratedNIC.Management.psd1
Add-AzureRMAccount
Get-AzureRmSubscription
$ID = '9ae25a43-e7eb-444e-9436-4957c838fad5'
Select-AzureRMSubscription -Subscription $ID
$RSGRoupName = 'Wieland-RDSH-RG'
$VMNAme = 'Wieland-GW01'
Add-AzureRmAcceleratedNIC -ResourceGroupName 'wieland-rdsh-rg' -VMName 'Wieland-GW01' -OsType windows