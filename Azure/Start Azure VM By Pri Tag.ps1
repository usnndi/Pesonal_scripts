 	$ResourceGroupName = 'CLEAN-RDSH-RG'
    $TenantID = '646d1891-1394-48d5-aaab-a2a67458a29d'
    $SubscriptionID = 'd61e40bc-f477-45bb-9b28-75d42b6c349f'
 	
 
    #The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    $CredentialAssetName = "Admin";
	
	#Get the credential with the above name from the Automation Asset stor
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName;

    #Connect to Azure Account
	Login-AzureRmAccount -Credential $Cred -TenantId $TenantID -SubscriptionId $SubscriptionID
    
    $VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName

    $VMSToTurnOn = $VMs | Where-Object {$_.Tags.Keys -eq 'Priority' -and $_.Tags.Values -eq '10'}

        foreach ($VM in $VMSToTurnOn){
                Write-Host "Starting " $VM.Name -foregroundcolor red -backgroundcolor yellow
                Start-AzureRmVM -Name $VM.Name -ResourceGroupName $ResourceGroupName
        }
