$VPNStatus = Get-VpnConnection

ForEach ($VPN in  $VPNStatus) 
{
if ($VPN.ConnectionStatus -eq 'Connected' -AND $VPN.Name -eq 'GRANGER')
{
Write-Host $VPN.Name, is $VPN.ConnectionStatus
Exit
}
}
Write-Host $VPN.Name"being disconnected."
C:\Windows\System32\rasdial.exe "/DISCONNECT"