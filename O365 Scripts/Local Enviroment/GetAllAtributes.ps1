PROCESS #This is where the script executes 
{ 
    #$path = Split-Path -parent "$CSVReportPath\*.*" 
    #$pathexist = Test-Path -Path $path 
    #If ($pathexist -eq $false) 
    #{New-Item -type directory -Path $path} 
     
    #$reportdate = Get-Date -Format ssddmmyyyy 
 
    #$csvreportfile = C:\Users\admin\Desktop + "\ALLADUsers_$reportdate.csv" 
     
    #import the ActiveDirectory Module 
    Import-Module ActiveDirectory 
     
    #Perform AD search. The quotes "" used in $SearchLoc is essential 
    #Without it, Export-ADUsers returuned error 
                  Get-ADUser -Properties * -Filter * |  
                  Select-Object @{Label = "SamAccount";Expression = {$_.sAMAccountName}},
                  #@{Label = "EmailBrand";Expression = {$_.extensionAttribute1}},
                  @{Label = "FirstName";Expression = {$_.GivenName}},  
                  @{Label = "LastName";Expression = {$_.Surname}}, 
                  @{Label = "DisplayName";Expression = {$_.DisplayName}}, 
                  @{Label = "Fulladdress";Expression = {$_.StreetAddress}}, 
                  @{Label = "City";Expression = {$_.City}}, 
                  @{Label = "State";Expression = {$_.st}}, 
                  @{Label = "PostCode";Expression = {$_.PostalCode}}, 
                  @{Label = "Country";Expression = {$_.Country}}, 
                  @{Label = "Title";Expression = {$_.Title}}, 
                  @{Label = "Company";Expression = {$_.Company}}, 
                  @{Label = "Description";Expression = {$_.Description}}, 
                  @{Label = "Department";Expression = {$_.Department}}, 
                  @{Label = "Office";Expression = {$_.OfficeName}}, 
                  @{Label = "Phone";Expression = {$_.telephoneNumber}},
                  @{Label = "Fax";Expression = {$_.facsimileTelephoneNumber}}, 
                  @{Label = "Manager";Expression = {%{(Get-AdUser $_.Manager -Properties DisplayName).DisplayName}}},
                  @{Label = "RebrandedSMTP";Expression = {$_.Mail}},
                  @{Label = "ADUserEmailAttribute";Expression = {$_.Mail}},
                  @{Label = "ADUserEmailAttriute";Expression = {$_.Mail}},
                  @{Label = "AccountStatus";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}}, # the 'if statement# replaces $_.Enabled 
                  @{Label = "Last LogOn Date";Expression = {$_.lastlogondate}},
                  @{Label = "UserPrincipleName";Expression = {$_.userPrincipalName}},
                  @{Label = "Proxyaddresses";Expression = {$_.proxyaddresses}} |  
                  #Export CSV report 
                  Export-Csv -path C:\Users\askadmin\Desktop\01092019HRC-ENGRDump.csv #-NoTypeInformation     
}