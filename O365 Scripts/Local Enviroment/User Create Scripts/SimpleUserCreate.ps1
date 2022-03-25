Import-Module ActiveDirectory
Import-Csv E:\DOWNLOADS\create_ad_users\SharedCreation.csv | foreach-object { 
$userprinicpalname = $_.SamAccountName + “@wielandbuilds.com” 
New-ADUser -SamAccountName $_.SamAccountName -UserPrincipalName $userprinicpalname -Name $_.name -DisplayName $_.name -GivenName $_.cn -SurName $_.sn -Department $_.Department -EmailAddress $_.Email -Title $_.Title -StreetAddress "4162 English Oak Dr." -City "Lansing" -State "MI" -PostalCode "48911" -Country "US" -OfficePhone "517-372-8650" -Fax "517-372-8961" -Path “OU=Shared Mailboxes,OU=Resources,OU=Wieland,DC=ad,DC=wielandbuilds,DC=com” -AccountPassword (ConvertTo-SecureString “W13l@ndUser;” -AsPlainText -force) -Enabled $True -PasswordNeverExpires $False -PassThru }
Set-ADUser -Identity $_.Username -EmailAddress $_Email
