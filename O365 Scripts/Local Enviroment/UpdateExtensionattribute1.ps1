Import-Csv C:\Temp\JASANDJAR.csv | Foreach {

$User = Get-ADUser -Identity $_.Logon

    if ($user.extensionattribute1 -eq $null){

    set-ADUser -Identity $user -Add @{extensionattribute1=$_.ExtensionAttribute1}
        }
    }