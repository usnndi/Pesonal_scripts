$storageAccount = "dlpremstor1"
$vmName ="DLVMTESTEAST2"
$vm = Get-AzureVM -ServiceName $vmName -Name $vmName
$LunNo = 1
$path = "http://" + $storageAccount + ".blob.core.windows.net/vhds/" + "myDataDisk_" + $LunNo + "_PIO.vhd"
$label = "Disk " + $LunNo
Add-AzureDataDisk -CreateNew -MediaLocation $path -DiskSizeInGB 128 -DiskLabel $label -LUN $LunNo -HostCaching ReadOnly -VM $vm | Update-AzureVm