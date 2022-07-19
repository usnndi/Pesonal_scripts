#Verified SAS for PriceList
# https://grangerencrearchstor.blob.core.windows.net/pricelistexport/*?sv=2020-10-02&se=2024-07-12T12%3A35%3A27Z&sr=c&sp=rl&sig=FjTeV2e9rYx9oWWKdUwN9%2FD4mZFbzy6KIg85iKhDKYM%3D

#Verified SAS for DB Backups
# https://grangerencrearchstor.blob.core.windows.net/encoredbbackup?sv=2020-10-02&st=2022-07-15T20%3A30%3A37Z&se=2030-07-16T20%3A30%3A00Z&sr=c&sp=rl&sig=tEhjoT9fYbFLhk5WOZy0hjYpSJNHfiTWKIC5gP9hhV4%3D

#Clean Out Old
#Remove-Item -Path "D:\Shared Files\Accounting Reports\EnCORE Pricing Data Files\*" -Force

#Stopping the script in case any error happens
$ErrorActionPreference = "Stop"

#Set Date 32 Daya Ago
$PLAge = 4
$StartDate = (get-date (get-date).addDays(-($PLAge)) -UFormat "%Y-%m-%d")
$Today = Get-Date -UFormat "%Y-%m-%d"

#Get Data
azcopy list "https://grangerencrearchstor.blob.core.windows.net/pricelistexport/*?sv=2020-10-02&se=2024-07-12T12%3A35%3A27Z&sr=c&sp=rl&sig=FjTeV2e9rYx9oWWKdUwN9%2FD4mZFbzy6KIg85iKhDKYM%3D" --properties "LastModifiedTime; ContentType" > C:\Temp\Granger\PriceListFiles.csv
(Get-Content -path "C:\Temp\Granger\PriceListFiles.csv" -Raw) -replace 'INFO: ', '' | Where-Object {$_ -ne ""} | Set-Content -Path "C:\Temp\Granger\PriceListFiles.csv"
Remove-Item -Path C:\Temp\Granger\PriceListFiles*.* -Force
$env:AZCOPY_CRED_TYPE = "Anonymous";


#Export-Csv -Path C:\Temp\Granger\PriceListFiles.csv -NoTypeInformation -Delimiter ";"     #> "C:\Temp\Granger\PriceListFiles.txt"
foreach ($line in Get-Content C:\Temp\Granger\PriceListFiles.txt) {
    $FileName = $Line.Split(':')[1].Split(';')[0].Trim()
        Write-Host $FileName
        Add-Content -Path "C:\Temp\Granger\FinalPriceListFilesList.txt" -Value $FileName | Where-Object {($FileName -contains $StartDate)}
    }