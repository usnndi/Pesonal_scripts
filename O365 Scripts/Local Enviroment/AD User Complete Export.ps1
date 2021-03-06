PROCESS #This is where the script executes 
{ 
    #$path = Split-Path -parent "$CSVReportPath\*.*" 
    #$pathexist = Test-Path -Path $path 
    #If ($pathexist -eq $false) 
    #{New-Item -type directory -Path $path} 
     
    #$reportdate = Get-Date -Format ssddmmyyyy 
 
    #$csvreportfile = C:\Users\admin\Desktop + "\ALLADUsers_$reportdate.csv" 
     
    #import the ActiveDirectory Module 
    #Import-Module ActiveDirectory 
     
    #Perform AD search. The quotes "" used in $SearchLoc is essential 
    #Without it, Export-ADUsers returuned error 
                  Get-MsolUser -All |  
                  Select-Object 
                  @{Label = "First Name";Expression = {$_.GivenName}},  
                  @{Label = "Last Name";Expression = {$_.Surname}}, 			      
                  @{Label = "Display Name";Expression = {$_.DisplayName}},                  
		          @{Label = "Logon Name";Expression = {$_.sAMAccountName}}, 
                  @{Label = "Full address";Expression = {$_.StreetAddress}}, 
                  @{Label = "City";Expression = {$_.City}}, 
                  @{Label = "State";Expression = {$_.st}}, 
                  @{Label = "Post Code";Expression = {$_.PostalCode}}, 
                  @{Label = "Country/Region";Expression = {if (($_.Country -eq 'GB')  ) {'United Kingdom'} Else {''}}}, 
                  @{Label = "Job Title";Expression = {$_.Title}}, 
                  @{Label = "Company";Expression = {$_.Company}}, 
                  @{Label = "Description";Expression = {$_.Description}}, 
                  @{Label = "Department";Expression = {$_.Department}}, 
                  @{Label = "Office";Expression = {$_.OfficeName}}, 
                  @{Label = "Phone";Expression = {$_.telephoneNumber}},
                  @{Label = "Fax";Expression = {$_.facsimileTelephoneNumber}}, 
                  @{Label = "Email";Expression = {$_.Mail}},
                  @{Label = "Manager";Expression = {%{(Get-MSOLUser $_.Manager -Properties DisplayName).DisplayName}}}, 
                  @{Label = "Account Status";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}}, # the 'if statement# replaces $_.Enabled 
                  @{Label = "Last LogOn Date";Expression = {$_.lastlogondate}}
                  @{Label = "SMTP";Expression = {$_.proxyaddresses}} |  
                   
                  #Export CSV report 
                  Export-Csv 'C:\Users\jloveall\OneDrive - ASK\Desktop\CentralO365Dump.csv' -NoTypeInformation     
}

Get-MsolUser | Where-Object { $_.isLicensed -eq "True"} | Select-Object -property DisplayName, UserPrincipalName, FirstName, LastName, department, Title, manager, StreetAddress, City, State, PostalCode, PhoneNumber, @{name="licenses";expression={$_.licenses.accountskuid}}, @{name="ProxyAddresses";expression={$_.ProxyAddresses -join ","}} | Export-Csv 'C:\Users\jloveall\OneDrive - ASK\Desktop\CentralO365Dump.csv'