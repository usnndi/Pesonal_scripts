$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session


Remove-PSSession -Session $Session


Import-Csv 'C:\Users\jloveall\ASK\Project Services Team - Working Data\NACUFS\Office 365 and Azure AD Migration (ASKQ7504)\GroupAdd.csv' | Foreach {
Add-DistributionGroupMember -Identity $_.GroupName -Member $_.Email
}