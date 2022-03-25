####            Search for "RD01" and replace for new RD Host Name     ####

#Set-AzureRmVM -ResourceGroupName wieland-rdsh-rg -Name wieland-rd0 -Generalized

#Set-AzureRmVm -ResourceGroupName <resourceGroup> -Name <vmName> -Generalized

#$vm = Get-AzureRmVM -ResourceGroupName wieland-rdsh-rg -Name wieland-rd0 -status
#$vm.Statuses

#Save-AzureRmVMImage -ResourceGroupName wieland-rdsh-rg -Name wieland-rd0 -DestinationContainerName vhd -VHDNamePrefix wielandrdimage -Path c:\users\jloveall\onedrive\desktop\wielandrdimage.json

#Wieland Azure Login
Login-AzureRmAccount

#Create variables
# Enter a new user name and password to use as the local administrator account for the remotely accessing the VM
$cred = Get-Credential

#Image Path
#$imageURI = 'https://biocarecmsv3sg.blob.core.windows.net/vhdupload/biocarecmsv3srsos-os-2017-11-12-4A1ED6B8.vhd'

# Name of the storage account 
$storageAccName = "biocarecmsv3sg"

# Name of the virtual machine
$vmName = "BIOCARECMSV3SRS"

# Size of the virtual machine. See the VM sizes documentation for more information: https://azure.microsoft.com/documentation/articles/virtual-machines-windows-sizes/
$vmSize = "Standard_DS2_V2"

# Computer name for the VM
$computerName = "BIOCARECMSV3SRS"

# Name of the disk that holds the OS
$osDiskName = "biocarecmsv3os"

# Assign a SKU name
# Valid values for -SkuName are: **Standard_LRS** - locally redundant storage, **Standard_ZRS** - zone redundant storage, **Standard_GRS** - geo redundant storage, **Standard_RAGRS** - read access geo redundant storage, **Premium_LRS** - premium locally redundant storage. 
$skuName = "Standard_LRS"

# Create a new storage account for the VM
#New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccName -Location $location -SkuName $skuName -Kind "Storage"

#Virtual Network Varialbles
$rgName = "BIOCARE-CMSV3-RG"
$location = "eastus2"
$locname = "eastus2"
$vnet = "BIOCARE-CMSV3-VN"
$vnetName = "BIOCARE-CMSV3-VN"
$subnetName = "Servers"
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
#$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix <0.0.0.0/0>

$ipName = "BIOCARE-CMSV3-PIP"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Static

$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName

$nicName = "biocarecmsv3-nic"
$nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName
# -Location $locName -SubnetId $vnetname.Subnets[0].Id -PublicIpAddressId $pip.Id

#Get the storage account where the uploaded image is stored
$storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName biocarecmsv3sg

#Set the VM name and size
#Use "Get-Help New-AzureRmVMConfig" to know the available options for -VMsize
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

#Set the Windows operating system configuration and add the NIC
#$vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$osDiskUri = "https://biocarecmsv3sg.blob.core.windows.net/vhds/biocarecmsv3srs-biocarecmsv3os.vhd"

$osDiskName = 'biocarecmsv3srs-biocarecmsv3os.vhd'

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Windows

New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm


#Create the OS disk URI
#$osDiskName = 'biocarecmsv3srs-biocarecmsv3os.vhd'
#$osDiskCaching = 'ReadWrite'
#$osDiskVhdUri = "https://biocarecmsv3sg.blob.core.windows.net/vhds/biocarecmsv3srs-biocarecmsv3os.vhd"

#$vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $osDiskVhdUri -name $osDiskName -CreateOption attach -Windows -Caching $osDiskCaching


#$osDiskUri = '{0}vhds/{1}-{2}.vhd' -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName
#$osDiskUri = 'https://wielandpremstor.blob.core.windows.net/imagevhd/wielandrdimage-osDisk.dab5a4cf-8917-419e-84fb-ab21289df3ed.vhd' -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName


#Configure the OS disk to be created from the image (-CreateOption fromImage), and give the URL of the uploaded image VHD for the -SourceImageUri parameter
#You set this variable when you uploaded the VHD
#$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption FromImage -SourceImageUri $imageuri -Windows

#Create the new VM
#New-AzureRmVM -ResourceGroupName BIOCARE-CMSV3-RG -Location "eastus2" -VM $vm