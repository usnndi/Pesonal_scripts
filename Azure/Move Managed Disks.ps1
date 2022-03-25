#Source storage account
$rgName ="ASK-VEEAM-MAIN-RG"
$location ="Central US"
$storageAccountName ="askveeamsource"
$diskName ="MAHP-VEEAM-DISK-1"

#Target storage account
$destrgName ="VEEAM-MAHP-RG"
$destlocation ="North Central US"
$deststorageAccountName ="askveeamo365stor"
$destdiskName ="MAHP-VEEAM-DISK-1"
 
#Assign access to the source disk
$sas =Grant-AzureRmDiskAccess -ResourceGroupName $rgName -DiskName $diskName -DurationInSecond 3600 -Access Read

$saKey =Get-AzureRmStorageAccountKey -ResourceGroupName $destrgName -Name $deststorageAccountName
$storageContext =New-AzureStorageContext –StorageAccountName $deststorageAccountName -StorageAccountKey $saKey[0].Value
New-AzureStorageContainer -Context $storageContext -Name vhds10261

Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer vhds10261 -DestContext $storageContext -DestBlob $destdiskName

Get-AzureStorageBlobCopyState -Context $storageContext -Blob $destdiskName -Container vhds10261