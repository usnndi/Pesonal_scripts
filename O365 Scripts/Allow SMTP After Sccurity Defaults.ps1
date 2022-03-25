#All you have to do is enable it in Powershell.  To connect with Powershell, first you have to execute this:
Connect-MsolService
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
#Then you enter your admin credentials.  After that, you can check the "smtp disabled" flag, it should be set to "true":
Get-TransportConfig | Format-List SmtpClientAuthenticationDisabled
#To enable smtp and get things working again, you enter this command:
Set-TransportConfig -SmtpClientAuthenticationDisabled $false