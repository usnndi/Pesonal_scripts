workflow StopBioCareSQLVM
{
    $Cred = Get-AutomationPSCredential -Name 'John Loveall'
    Add-AzureAccount -Credential $Cred
    
InlineScript 
    {

    Select-AzureSubscription -SubscriptionName "ASK Tenants"
           
    $VMS = 'biocarecmsv3srs' 

    foreach($VM in $VMS)
        {    
        $VMName = $VM.Name 
        Stop-AzureVM -ServiceName biocarecmsv3srs -Name biocarecmsv3srs -Force
        Write-Output "Shutting down VM :  biocarecmsv3srs"
        }
    }
}