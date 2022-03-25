#Copy Disks From Blob to Blob
$sourceBlobUri = "https://tricountytitle.blob.core.windows.net/vhds/tctrdshupdstor.vhd"
$sourceContext = New-AzureStorageContext  –StorageAccountName tricountytitle -StorageAccountKey 30JU8zIRU59++AWnbOJRrL6WK+TczIyIfOKzuyj73LeJaGfZwc1dYnhWO1C1d9YI/9s3uwyuvJUC0dtl19G4cQ==
$destinationContext = New-AzureStorageContext  –StorageAccountName tricountytitle -StorageAccountKey 30JU8zIRU59++AWnbOJRrL6WK+TczIyIfOKzuyj73LeJaGfZwc1dYnhWO1C1d9YI/9s3uwyuvJUC0dtl19G4cQ==
Start-AzureStorageBlobCopy -srcUri $sourceBlobUri -SrcContext $sourceContext -DestContainer "tctrdsh" -DestBlob "tricountytitle-tctrdsh-2015-05-08.vhd" -DestContext $destinationContext

#Register Disks
Add-AzureDisk -DiskName "TCTRDSHOS" -MediaLocation "https://tricountytitle.blob.core.windows.net/tctrdsh/tricountytitle-tctrdsh-2015-05-08.vhd" -Label "TCTA RDSH OS" -OS "Windows"

Add-AzureDisk -DiskName "DataDisk" -MediaLocation "https://tctpremstor.blob.core.windows.net/images/tctrdshupdstor.vhd" -Label "TCTRDSH Data"

#Create VM
$serviceName = "TCTRDSH"
$location = "East US"
$vmSize ="Standard_DS4"
$adminUser = "Setup"
$adminPassword = "Access011"
$vmName ="TCTRDSH"
$vmSize = "Standard_DS4"


New-AzureVMConfig -Name "tctrdsh" -InstanceSize "Standard_DS4" -DiskName "TCTRDSHOS" | Add-AzureProvisioningConfig -Windows | Add-AzureDataDisk -LUN 0 -DiskLabel "DataDisk" -ImportFrom -MediaLocation "https://tricountytitle.blob.core.windows.net/tctrdsh/tctrdshupdstor.vhd" | New-AzureVM -ServiceName "tctrdsh" –Location “East US”

Add-AzureDisk -DiskName "TCTRDSHNEWOS" -MediaLocation "https://tctpremstor.blob.core.windows.net/vhds/tctrdsh-os.vhd" -OS "Windows"

Get-AzureSubscription –SubscriptionName “ASK Tenants” | Select-AzureSubscription