Select-AzureSubscription "005c8982-4774-4c88-808a-fd4f82d1367b" 

# VHD blob to copy #
$blobName = "DLVMTEST-DLVMTEST-os-1441905268979.vhd" 

# Source Storage Account Information #
$sourceStorageAccountName = "dleaststor"
$sourceKey = "miiIsC31C3v6rBWfcfbHEzs55/fbHkUobt32xOuNNrBWGVXJrvwof5zwf6mhtiX2mHV9UPinLzLuMozfBKBjBg=="
$sourceContext = New-AzureStorageContext –StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceKey  
$sourceContainer = "vhds"

# Destination Storage Account Information #
$destinationStorageAccountName = "dleast2stor"
$destinationKey = "DOsupvTVqJUJf3YMEHPfbhJc67f+yco9A6xS9PaM24LkeTnLCIWH7HbQECSdYLKdHbvHC76G4M/j9GZUqkS2tQ=="
$destinationContext = New-AzureStorageContext –StorageAccountName $destinationStorageAccountName -StorageAccountKey $destinationKey  

# Create the destination container #
$destinationContainerName = "vhds"
New-AzureStorageContainer -Name $destinationContainerName -Context $destinationContext 

# Copy the blob # 
$blobCopy = Start-AzureStorageBlobCopy -DestContainer $destinationContainerName `
                        -DestContext $destinationContext `
                        -SrcBlob $blobName `
                        -Context $sourceContext `
                        -SrcContainer $sourceContainer