    Connect-MSOLService 
    import-csv C:\Users\jloveall\OneDrive\Desktop\Wieland\Project.csv | ForEach-Object { 
        Set-MsolUser -UserPrincipalName $_.UPN -UsageLocation US
        Set-MsolUserLicense -UserPrincipalName $_.UPN -AddLicenses "reseller-account:PROJECTPROFESSIONAL"
    }