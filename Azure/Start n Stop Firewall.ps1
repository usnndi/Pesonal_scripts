#Install-Module AzureRM.Network

#Login
Connect-AzAccount


## Stop Firewall and Set Route to Azure Load Balancer
#Set Route to Use Azure Load Balancer
Get-AzRouteTable -Name SEI-EDGE-RT -ResourceGroupName SEI-PROD-RG | Set-AzRouteConfig -AddressPrefix 0.0.0.0/0 -Name Internet -NextHopType Internet | Set-AzRouteTable

# Stop an existing firewall
$azfw = Get-AzFirewall -Name "SEI-VNET-FW" -ResourceGroupName "SEI-PROD-RG"
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

## Start Firewall and Set Route to Firewall
# Start a firewall
$azfw = Get-AzFirewall -Name "SEI-VNET-FW" -ResourceGroupName "SEI-PROD-RG"
$vnet = Get-AzVirtualNetwork -ResourceGroupName "SEI-PROD-RG" -Name "SEI-PROD-CENT-EDGE-VN"
$publicip = Get-AzPublicIpAddress -Name "SEI-VNET-FW-PIP" -ResourceGroupName "SEI-PROD-RG"
$azfw.Allocate($vnet,$publicip)
Set-AzFirewall -AzureFirewall $azfw

#Set AZ FW as Default Route
Get-AzRouteTable -Name SEI-EDGE-RT -ResourceGroupName SEI-PROD-RG | Set-AzRouteConfig -AddressPrefix 0.0.0.0/0 -Name Internet -NextHopIpAddress 10.30.254.68 -NextHopType VirtualAppliance | Set-AzRouteTable
