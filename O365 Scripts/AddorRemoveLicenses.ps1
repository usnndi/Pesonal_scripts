Connect-AzureAD
$licsense = "marsdelivers:EXCHANGEENTERPRISE"
$remove = "marsdelivers:ENTERPRISEPACK"
$bprem = "marsdelivers:SPB"
Import-Csv C:\Temp\mars.csv | Foreach {
Set-MsolUserLicense -UserPrincipalName $_.UPN -AddLicenses "marsdelivers:EXCHANGEENTERPRISE"
}