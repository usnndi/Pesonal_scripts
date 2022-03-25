Import-Csv “E:\DOWNLOADS\User Create Scripts\HideFromGAL\Hide.csv” | Foreach {
                Write-Host "User:" $_.SamAccountName 
                Get-ADUser $_.SamAccountName | set-aduser -Replace @{msExchHideFromAddressLists="TRUE"}

}