workflow SetReserverdIP
{
    $Cred = Get-AutomationPSCredential -Name 'John Loveall'
    Add-AzureAccount -Credential $Cred
    
InlineScript 
    {

    Select-AzureSubscription -SubscriptionName "ASK Tenants"
           
    Set-AzureReservedIPAssociation -ReservedIPName "Group biocare biocarecmsv3srs"  -ServiceName biocarecmsv3srs

    }
}