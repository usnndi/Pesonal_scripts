$local = Get-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName testrg
Set-AzureRmLocalNetworkGateway -LocalNetworkGateway $local -AddressPrefix @('172.16.1.0/24')