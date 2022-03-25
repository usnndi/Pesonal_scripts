$VMName = 'BIOCARECMSV3SRS'
$VMsize = 'Standard_DS2_V2'
$VMVNET = 'BIOCARE-CMSV3-VN'
$VMNETRG = 'BIOCARE-CMSV3-RG'
$VMSubnet = 'Server'
$VMIP = '172.23.1.20'
$OsDiskUri  = 'https://biocarecmsv3sg.blob.core.windows.net/vhds/biocarecmsv3srs-biocarecmsv3os.vhd'
$DestRG = 'BIOCARE-CMSV3-RG'
$Region = 'eastus2'
$VNICName = 'biocarecmsv3-nic'
Login-AzureRmAccount
#Select-azurermsubscription -subscriptionName 'Your sub Name'

$VM = New-AzureRmVMConfig -VMName $VMName -VMSize $VMsize
$VMVNETObject = Get-AzureRmVirtualNetwork -Name  $VMVNET -ResourceGroupName $VMNETRG
$VMSubnetObject = Get-AzureRmVirtualNetworkSubnetConfig -Name $VMSubnet -VirtualNetwork $VMVNETObject

$VNIC = New-AzureRmNetworkInterface -Name $VNICName -ResourceGroupName $DestRG -Location eastus2 -SubnetId $VMSubnetObject.Id -PrivateIpAddress $VMIP

Add-AzureRmVMNetworkInterface -VM $VM -Id $VNIC.Id

Set-AzureRmVMOSDisk -VM $VM -Name $VMName -VhdUri $OsDiskUri -CreateOption "Attach" -Windows 

$NEWVM = New-AzureRmVM -ResourceGroupName $DestRG -Location $Region -VM $VM