#Select-AzureRmSubscription -SubscriptionName 'Microsoft Azure (wielandbuildsask): #1057540'
$rgName = "wieland-rdsh-rg"
$vmName = "Wieland-SQL01"
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force
ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $rgName -VMName $vmName
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName