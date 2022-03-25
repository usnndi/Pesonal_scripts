## Convert existing Azure VMs to managed disks of the same storage type

#Azure Login
Login-AzureRmAccount

## Set VM Resource & VM Variables
$rgName = "BIOCARE-CMSV3-RG"
$vmName = "BIOCARECMSV3SRS"
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force

## Convert Disks
ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $rgName -VMName $vmName

$rgName = 'BIOCARE-CMSV3-RG'
$vmName = 'BIOCARECMSV3'
$location = 'East US 2' 
$storageType = 'Standard_LRS'
$dataDiskName = 'BIOCARE-CMSV3-MANAGEDOSDISK'

$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Empty -DiskSizeGB 512

$dataDisk1 = New-AzureRmDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName 

$vm = Add-AzureRmVMDataDisk $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 4

Update-AzureRmVM -VM $vm -ResourceGroupName $rgName
