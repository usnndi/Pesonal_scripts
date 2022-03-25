Import-Csv C:\Users\admin\Desktop\ReBranding\07082017-FowlervilleUsersImport.csv | Foreach {

$User = Get-ADUser -Identity $_.SamAccount

    #if ($user.street -eq $null){

   #set-ADUser -Identity $user -Clear extensionattribute1
   #set-ADUser -Identity $user -Replace @{extensionattribute1=$_.EmailBrand}
   #set-ADUser -Identity $user -Clear StreetAddress
   #set-ADUser -Identity $user -Replace @{StreetAddress=$_.Fulladdress}
   #set-ADUser -Identity $user -Clear l
   #set-ADUser -Identity $user -Replace @{l=$_.City}
   #set-ADUser -Identity $user -Clear St
   #set-ADUser -Identity $user -Replace @{St=$_.State}
   #set-ADUser -Identity $user -Clear postalCode
   #set-ADUser -Identity $user -Replace @{postalCode=$_.PostCode}
   #set-ADUser -Identity $user -Clear C
   #set-ADUser -Identity $user -Replace @{C=$_.Country}
   #set-ADUser -Identity $user -Clear Company
   #set-ADUser -Identity $user -Replace @{Company=$_.Company}
   #set-ADUser -Identity $user -Clear telephoneNumber
   #set-ADUser -Identity $user -Replace @{telephoneNumber=$_.Phone}
   #set-ADUser -Identity $user -Clear facsimileTelephoneNumber
   #set-ADUser -Identity $user -Replace @{facsimileTelephoneNumber=$_.Fax}
   #set-ADUser -Identity $user -Clear title
   #set-ADUser -Identity $user -Replace @{title=$_.Title}
   set-ADUser -Identity $user -Clear mail
   set-ADUser -Identity $user -Replace @{mail=$_.ADUserEmailAttribute}

        }