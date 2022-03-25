#Path to the Static Department Import File
#**Make Sure the Columns match the daily import file**
$department = "C:\Users\jloveall\OneDrive - ASK\Desktop\AMBS\JMFamilyDepartment.csv”
#This is the path to the daily import downloaded
$import = "C:\Users\jloveall\OneDrive - ASK\Desktop\AMBS\Users.csv"

#Says whether to ignore the first line of the Import File
$getFirstLine = $false

#Copies the content to the daily import download
get-childItem "$department" | foreach {
    $filePath = $_

    $lines =  $lines = Get-Content $filePath  
    $linesToWrite = switch($getFirstLine) {
           $true  {$lines}
           $false {$lines | Select -Skip 1}

    }

    $getFirstLine = $false
    Add-Content $import $linesToWrite
    }