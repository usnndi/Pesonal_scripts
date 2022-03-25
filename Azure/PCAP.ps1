#Start PCAP
Start-AzVirtualNetworkGatewayPacketCapture -ResourceGroupName "SEI-PROD-RG" -Name "SEIPROD-VNG"

#Stop PCAP
$rgname = "SEI-PROD-RG"
 $storeName = "seiprodrgdiag"
 $containerName = "imwpcap"
 $key = Get-AzStorageAccountKey -ResourceGroupName $rgname -Name $storeName
 $context = New-AzStorageContext -StorageAccountName $storeName -StorageAccountKey $key[0].Value
 $container = Get-AzStorageContainer -Name $containerName -Context $context
 $now=get-date
 $sasurl = New-AzStorageContainerSASToken -Name $containerName -Context $context -Permission "rwd" -StartTime $now.AddHours(-1) -ExpiryTime $now.AddDays(1) -FullUri
 $gw = Get-AzVirtualNetworkGateway -ResourceGroupName $rgname -name "SEIPROD-VNG"
Stop-AzVirtualNetworkGatewayPacketCapture -InputObject $gw -SasUrl $sasurl
