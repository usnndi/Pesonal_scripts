Uninstall-Module -Name AutoTask -Force
Install-Module -Name AutoTask -Force
Import-Module -Name AutoTask
Connect-AtwsWebAPI -ApiTrackingIdentifier DTRSLWN6BY4EAEOFAVLJM6CIJNA -Credential powershellapi@JUSTASK.NET
Update-AtwsFunctions -FunctionSet static

#Extend Expired COntracts
Import-Csv C:\Temp\ATPS\extend.csv | Foreach {
Write-Host $_.Contract" Extending End Date."
Get-AtwsContract -ContractName $_.Contract | Set-AtwsContract -EndDate "05/31/2021"
}


#Inactivate Completed Project Contracts
Import-Csv C:\Temp\ATPS\complete.csv | Foreach {
Write-Host $_.Contract" Marked as Inactive."
Get-AtwsContract -ContractName $_.Contract | Set-AtwsContract -Status Inactive
}


Get-AtwsProject | ForEach
if ($_.Status -ne "Complete") { Export-Csv C:\Temp\Noncomplete.csv } 
else { Write-Host -ForegroundColor Green "Finished" }


Get-AtwsProject -NotEquals Status -Status Complete