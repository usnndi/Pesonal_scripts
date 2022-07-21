#Verified SAS for PriceList
# https://grangerencrearchstor.blob.core.windows.net/pricelistexport/*?sv=2020-10-02&se=2024-07-12T12%3A35%3A27Z&sr=c&sp=rl&sig=FjTeV2e9rYx9oWWKdUwN9%2FD4mZFbzy6KIg85iKhDKYM%3D

#Verified SAS for DB Backups
# https://grangerencrearchstor.blob.core.windows.net/encoredbbackup?sv=2020-10-02&st=2022-07-15T20%3A30%3A37Z&se=2030-07-16T20%3A30%3A00Z&sr=c&sp=rl&sig=tEhjoT9fYbFLhk5WOZy0hjYpSJNHfiTWKIC5gP9hhV4%3D

#Clean Out Old
#Remove-Item -Path "D:\Shared Files\Accounting Reports\EnCORE Pricing Data Files\*" -Force

#Stopping the script in case any error happens
$ErrorActionPreference = "Stop"

#Set Date 32 Daya Ago
$PLAge = 32
$StartDate = (get-date (get-date).addDays(-($PLAge)) -UFormat "%Y-%m-%d")
$Today = Get-Date -UFormat "%Y-%m-%d"

#Get Data
azcopy cp "https://grangerencrearchstor.blob.core.windows.net/pricelistexport/*?sv=2020-10-02&se=2024-07-12T12%3A35%3A27Z&sr=c&sp=rl&sig=FjTeV2e9rYx9oWWKdUwN9%2FD4mZFbzy6KIg85iKhDKYM%3D" "C:\Shared Files\Accounting Reports\EnCORE Pricing Data Files" --preserve-last-modified-time --include-after $StartDate

#Delete files older than 2 months
Get-ChildItem "D:\Shared Files\Accounting Reports\EnCORE Pricing Data Files" -Recurse -Force -ea 0 |
Where-Object {!$_.PsIsContainer -eq $True -and $_.LastWriteTime -lt (Get-Date).AddDays(-32)} |
ForEach-Object {
   $_ | Remove-Item -Force
}