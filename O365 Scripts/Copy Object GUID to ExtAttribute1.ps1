$users = Get-ADUser -Filter * -Properties objectguid, extensionattribute1

foreach ($user in $users){
    
    if ($user.extensionattribute1 -eq $null){

    set-ADUser -Identity $user -Replace @{extensionattribute1=$user.objectguid}
        }
    } 
