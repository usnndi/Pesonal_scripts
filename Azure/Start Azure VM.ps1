$ResourceGroupName = 'ASK-POWERBI-RG'
$TenantID = '7e133024-7fde-4ba2-befa-780f31dbab00'
$SubscriptionID = '866a4733-f64e-42f9-8244-f40ab7a089c6'
$pass = ConvertTo-SecureString "9563B3nt0n5" -AsPlainText –Force
$cred = New-Object -TypeName pscredential –ArgumentList "jloveall@justask.net", $pass

Login-AzureRmAccount -Credential $cred -ServicePrincipal –TenantId $TenantID
Select-AzureSubscription -SubscriptionID $SubscriptionID

{
           
$VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName

$VMSToTurnOn = $VMs# | Where-Object {$_.Tags.Keys -eq 'Priority' -and $_.Tags.Values -eq '10'}

        foreach ($VM in $VMSToTurnOn){
                Write-Host "Starting " $VM.Name -foregroundcolor red -backgroundcolor yellow
                Start-AzureRmVM -Name $VM.Name -ResourceGroupName $ResourceGroupName
        }
    }
}
#Login-AzureRmAccount -Credential -