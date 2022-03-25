Add-AzureDisk -DiskName "OSDisk" -MediaLocation "https://tctpremstorssd.blob.core.windows.net/vhds/tctpremstortest-tctpremstortest-2015-12-05.vhd" -Label "TCTPREM OS Disk" -OS "Windows"

AzCopy /Source: https://tricountytitle.blob.core.windows.net/vhds/ /SourceKey: 30JU8zIRU59++AWnbOJRrL6WK+TczIyIfOKzuyj73LeJaGfZwc1dYnhWO1C1d9YI/9s3uwyuvJUC0dtl19G4cQ== /Dest: https://tricountytitleprem.blob.core.windows.net/vhds /DestKey: Kv3R8KqhLAuo4+KgKFb2fNYfEjK57lJ07iYzxiIN8ufNBavMu1Capt2Nn+X+k7jgn7X0XQf5veZStn5LJnJ53w== /BlobType:page /Pattern: tricountytitle-tctrdsh-2015-05-08.vhd

#Register OS Disk Generlized
Add-AzureVMImage -ImageName "OSImageName" -MediaLocation "https://storageaccount.blob.core.windows.net/vhdcontainer/osimage.vhd" -OS Windows
Add-AzureDisk -DiskName "tctrdshpremos" -MediaLocation "https://tricountytitleprem.blob.core.windows.net/vhds/myvhd.vhd" -OS "Windows"

#New VM
New-AzureVMConfig -Name "TCTRDSHPrem" -InstanceSize "Standard_DS4" -DiskName "TCTRDPremOS" | Add-AzureProvisioningConfig -Windows | Set-AzureSubnet -SubnetNames Subnet-1 | New-AzureVM -ServiceName "tricountytitleprem " –Location “East US” -VNetName TCTNetwork


#Register OS Disk Specific
Add-AzureDisk -DiskName "tctrdshpremos" -MediaLocation "https://tctpremstorssd.blob.core.windows.net/copy/tctpremstormir2.vhd" -Label "TCT Prem Mirror 2" -OS "Windows"


$SubscriptionName = 'Pay-As-You-Go'
Select-AzureSubscription -SubscriptionName $SubscriptionName –Default

#Azcopy Usage
AzCopy /Source: <source> /SourceKey: <source-account-key> /Dest: <destination> /DestKey: <dest-account-key> /BlobType:page /Pattern: <file-name>

#Copy VHD to New Storage
$sourceBlobUri = "https://tricountytitle.blob.core.windows.net/vhds/tctrdsh-userdata.vhd"
$sourceContext = New-AzureStorageContext  –StorageAccountName tricountytitle -StorageAccountKey 30JU8zIRU59++AWnbOJRrL6WK+TczIyIfOKzuyj73LeJaGfZwc1dYnhWO1C1d9YI/9s3uwyuvJUC0dtl19G4cQ==
$destinationContext = New-AzureStorageContext  –StorageAccountName tricountytitleprem -StorageAccountKey Kv3R8KqhLAuo4+KgKFb2fNYfEjK57lJ07iYzxiIN8ufNBavMu1Capt2Nn+X+k7jgn7X0XQf5veZStn5LJnJ53w==
Start-AzureStorageBlobCopy -srcUri $sourceBlobUri -SrcContext $sourceContext -DestContainer "vhds" -DestBlob "tctrdsh-userdata.vhd" -DestContext $destinationContext

$status = tctrdsh-userdata.vhd | Get-AzureStorageBlobCopyState 

Add-AzureDisk -DiskName "TCTRDSHPremOS" -MediaLocation "https://tricountytitleprem.blob.core.windows.net/vhds/tctrdshpremos.vhd" -Label "TCTRDSH Prem OS" -OS "Windows"

Add-AzureDisk -DiskName "TCTRDSHData" -MediaLocation "https://tricountytitleprem.blob.core.windows.net/vhds/tctrdsh-userdata.vhd" -Label "TCTRDSH User Data"