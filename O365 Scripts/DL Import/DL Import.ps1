$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

Import-CSV "Q:\Dentco\PROJECTS\2015 Projects\O365\Imports\Dentco Distribution List.csv" | foreach {New-DistributionGroup -Name $_.name -Type $_.Type}