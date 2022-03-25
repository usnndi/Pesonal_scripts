$credential = Get-Credential
Connect-MsolService
Connect-AzureAD
Connect-ExchangeOnline
Get-MsolAccountSku

Start-Transcript C:\Temp\_Working\LicenseOut.txt
Import-Csv C:\Temp\_Working\mbc.csv | Foreach {
Add-DistributionGroupMember -Identity "MBC-M365-Defender-Pilot" -Member $_.User
$User = $_.User
$UserObj = Get-MsolUser -UserPrincipalName $User
Write-Host $User
#Add-MsolGroupMember -GroupObjectId "ea2ce34f-7c28-431c-997f-36a4f0415871" -GroupMemberObjectId $UserObj.ObjectId
Set-MsolUserLicense -UserPrincipalName $User -RemoveLicenses "reseller-account:ENTERPRISEPACK"
Set-MsolUserLicense -UserPrincipalName $User -AddLicenses "reseller-account:SPB"
}
Stop-Transcript