Login-AzureRmAccount

Select-AzureRmSubscription -Subscription 9ae25a43-e7eb-444e-9436-4957c838fad5

#Provide the subscription Id
$subscriptionId = '9ae25a43-e7eb-444e-9436-4957c838fad5'

#Provide the name of your resource group
$resourceGroupName ='Wieland-RDSH-RG'

#Provide the name of the snapshot that will be used to create Managed Disks
$snapshotName = 'ImageofRD'

#Provide the name of the Managed Disk
$diskName = 'wieland-rd06-os'

#Provide the size of the disks in GB. It should be greater than the VHD file size.
$diskSize = '128'

#Provide the storage type for Managed Disk. PremiumLRS or StandardLRS.
$storageType = 'PremiumLRS'

#Provide the Azure region (e.g. westus) where Managed Disks will be located.
#This location should be same as the snapshot location
#Get all the Azure location using command below:
#Get-AzureRmLocation
$location = 'eastus2'

#Set the context to the subscription Id where Managed Disk will be created
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

$snapshot = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName 
 
$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id
 
New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $diskName