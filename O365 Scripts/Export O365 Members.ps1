Import-Csv C:\Temp\GroupsNames.csv -Header Name, DisplayName | Foreach-object {
Get-UnifiedGroup -Identity $_.Name | Get-UnifiedGroupLinks -LinkType Member | select Name,PrimarySMTPAddress | export-csv c:\Temp\$_.Name.csv
}