cls
# Login-AzureRmAccount
# Variables
$ResourceGroupName = "Wieland-RDSH-RG"
$VMName = "Wieland-RD01"
#$VMSize = "Standard_A3"
$VMSize = "Standard_A4"
$starttime = get-date -format hh:mm:ss
$endtime = get-date -format hh:mm:ss
Write-host "Starting resize at " $starttime # Shut down VM
# VM must be shut down before size change to switch between A/D/DS/Dv2/G/GS/N 
# Stop-AzureRmVm -name $VMName -ResourceGroupName $ResourceGroupName -StayProvisioned -Force
# Resize VM 
$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName
$vm.HardwareProfile.VMSize = $VMSize
#Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm
# Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm $endtime = get-date -format hh:mm:ss
$time = New-TimeSpan -Start $starttime -End $endtime
write-host "Resize finished. Time to complete: " $time.minutes"minute(s) and "$time.seconds "seconds." # Start VM Start-AzureRmVm -name $VMName -ResourceGroupName $ResourceGroupName