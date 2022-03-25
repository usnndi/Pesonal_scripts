
Login-AzureRmAccount

Get-AzureRmSubscription

Select-AzureSubscription "Microsoft Azure (wielandbuildsask): #1057540" 

# VHD blob to copy #
$blobName = "b9219331346de43cbbd41ed85ff53f1e0.vhd" 

# Source Storage Account Information #
$sourceStorageAccountName = "wielandstor"
$sourceKey = "CO5KCAzNRxs789Ef+xD3Qd1op3DegPXORQ5PDExewoYCAurmJbXzs2+nCEhGkqKLap4UMbmRETWDHZP8n6rY5A=="
$sourceContext = New-AzureStorageContext –StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceKey  
$sourceContainer = "vhd241fe002c11040cfb78872cb3bd2fd93"

# Destination Storage Account Information #
$destinationStorageAccountName = "wielandpremstor"
$destinationKey = "Baq9riiRGGKvuDW4HzB0srnwCsHdfwfDbXKgaQBUI8TilxHbbc2jVKZbXEl9s3qVcTMWJwH/7XiSERZFLfeiGQ=="
$destinationContext = New-AzureStorageContext –StorageAccountName $destinationStorageAccountName -StorageAccountKey $destinationKey  

# Create the destination container #
$destinationContainerName = "imagevhd"
New-AzureStorageContainer -Name $destinationContainerName -Context $destinationContext 

# Copy the blob # 
$blobCopy = Start-AzureStorageBlobCopy -DestContainer $destinationContainerName `
                        -DestContext $destinationContext `
                        -SrcBlob $blobName `
                        -Context $sourceContext `
                        -SrcContainer $sourceContainer