CLS
CD E:\WIELAND-DATA\User-Data\User-Home
Import-CSV "E:\DOWNLOADS\User Create Scripts\HomeRename.csv" | % {
Rename-Item -NewName $_.AzureLogin -Path $_.ViewpointSAM
}