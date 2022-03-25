    #Connect-MSOLService 
    import-csv 'C:\Users\jloveall\ASK\Project Services Team - Working Data\CENTRAL STAR\EMAIL & DOMAIN Consolidation\GsuitetoO365\ECRemoveFWD.csv' | ForEach-Object { 
        Write-Host "Updating" $_.Username
        Set-Mailbox $_.Username -ForwardingAddress $Null
        #set-User -Identity $_.EmployeeUsername -Manager $_.ManagerUsername
        #set-User -Identity  Kurt.Barnes@mycentralstar.com -Manager Eric.Westphal@mycentralstar.com
        #Set-MailContact -Identity $_.Alias -HiddenFromAddressListsEnabled $true
        #Set-MsolUser -UserPrincipalName $_.Username -UsageLocation US
        #Set-MsolUserLicense -UserPrincipalName $_.Username -AddLicenses "NorthStarCooperative:O365_BUSINESS_ESSENTIALS"
}

    #Get-MsolAccountSku
