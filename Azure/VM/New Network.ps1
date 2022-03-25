Login-AzureRmAccount

Get-AzureRmSubscription

$rgName = "Wieland-RDSH-RG"
$location = "eastus2"
$subnetName = "Servers"
$singleSubnet = "servers"

$vnetName = "<vnetName>"
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName

$ipName = "<ipName>"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic

$nicName = "<nicName>"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

