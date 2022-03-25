#Import Modules
Import-Module ActiveDirectory

#Set Customer Site Variables
$DomainName = "EmailDomain.com" #use the customer's primary email domain
$Path = "CN=Users,DC=contoso,DC=local" #Note that the CN may need to be OU

#User Inpur variables. Do not change.
$Username = Read-Host -Prompt "Username"
$Fisrtname = Read-Host -Prompt "First Name"
$Lastname = Read-Host -Prompt "Last Name"
$Displayname = Read-Host -Prompt "Display Name"
$Password = Read-Host -Prompt "Password"
$EmailAddress = Read-Host -Prompt "Email Address"

#Convert password srting into a secure string
$SecPass = ConvertTo-SecureString $Password -AsPlainText -Force

#Add the user to Active Directory
New-ADUser -SamAccountName $Username -GivenName $Fisrtname -Surname $Lastname -DisplayName $Displayname -Name $Displayname -Path $Path -UserPrincipalName "$Username@$DomainName" -PasswordNeverExpires $true -AccountPassword $SecPass -EmailAddress $EmailAddress -Enabled $true -OtherAttributes @{'proxyAddresses'="SMTP:$EmailAddress"}