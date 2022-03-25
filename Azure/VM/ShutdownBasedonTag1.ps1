<#
    .SYNOPSIS 
    Stops all the Azure VMs in a specific Azure Resource Group based on a priority tag

    .DESCRIPTION
    This runbook stops all of the virtual machines in the specified Azure Resource Group, in order, based on the value of the Priority tag.
    It is particularly useful for CSP (Cloud Solution Provider) customers, or users who have multiple subscriptions, as both Tenant ID and Subscription ID can 
    be specified.

    Note: Edit the $CredentialAssetName to match your Automation Credential Asset name.
    The account should have VM Contributor rights on the Resource Group you are targeting, or the ability to perform the “stop” VM action.
    More info on creating custom RBAC roles can be found here: 
    https://azure.microsoft.com/en-us/documentation/articles/role-based-access-control-configure/#custom-roles-in-azure-rbac

    .PARAMETER ResourceGroupName
    Required
    Name of the Azure Resource Group containing the VMs to be stopped.

    .PARAMETER TenantID
    Required
    Tenant ID of the Azure account you are targeting (use Get-AzureRMSubscription to view). This should be provided in 
    the format xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx

    .PARAMETER SubscriptionID
    Required
    Subscription ID of the Azure subscription that the Resource Group resides in (use Get-AzureRMSubscription to view). 
    This should be provided in the format xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx

    .REQUIREMENTS 
    This runbook makes use of the Azure Resource Manager PowerShell global module (now included
    in Azure Automation)
    Each VM must have a tag called "Priority" with a value between 1 and 10. The lower number gets turned off last (e.g. 10, 9, 8...2, 1)

    .NOTES
    This runbook was originally created to power off Virtual Machines overnight and at weekends to prevent charging for 
    resources that are not needed 24x7, it is also ideal for Dev / Test labs. 
    The priority tag is useful if there are VMs or appliances which need to be powered off after other resources.

    AUTHOR: Jay Avent 
    LASTEDIT: Apr 28, 2016

#>

 workflow Stop-VM-Pri-10 {
 	$ResourceGroupName = 'Wieland-RDSH-RG'
    $TenantID = 'bc0ad702-e580-4e6f-ab94-90b26d7a636b'
    $SubscriptionID = '9ae25a43-e7eb-444e-9436-4957c838fad5'
 	
 
  #The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    #Get-AutomationPSCredential -Name 'Wieland-RM-VM-Creds'
    $CredentialAssetName = "Admin";
	
	#Get the credential with the above name from the Automation Asset stor
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName;
    #if(!$Cred) {
    #    Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    #}

    #Connect to Azure Account
	Login-AzureRmAccount -Credential $Cred -TenantId $TenantID -SubscriptionId $SubscriptionID
    
    $VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName

    #for ($i = 9)
    #{ 
    $VMSToTurnOff = $VMs | Where-Object {$_.Tags.Keys -eq 'Priority' -and $_.Tags.Values -eq '9'}

        foreach ($VM in $VMSToTurnOff){
            #Stop-AzureRmVM -Name $VM.Name -ResourceGroupName $ResourceGroupName -Force
            Start-AzureRmVM -Name $VM.Name -ResourceGroupName $ResourceGroupName
        }
    #}

}