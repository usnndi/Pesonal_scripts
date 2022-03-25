#Start-Transcript -Path "C:\Users\setup\Desktop\DobieRoadUpdates\SIP.txt" -NoClobber
$newDomain = "dobieroad.org"
$userou = 'OU=Information Technology,OU=Users,OU=ICMCF,DC=icmcf,DC=pvt'

#$users = Import-Csv users.csv
#or
$users = Get-ADUser -Filter * -SearchBase $userou -Properties SamAccountName, EmailAddress, ProxyAddresses

foreach ($user in $users) {
    $sipProxy = (Get-ADUser $user -Properties ProxyAddresses).ProxyAddresses | ? { $_ -like "x500:*" }
        foreach ($proxy in $sipProxy) {
            Set-ADUser $user -Remove @{ProxyAddresses=$proxy}
}
}
#Stop-Transcript