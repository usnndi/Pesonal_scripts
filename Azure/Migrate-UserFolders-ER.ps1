import-module activedirectory


$users = Get-ADUser -SearchBase "OU=EatonRapids-OLD,DC=ER,DC=local" -filter *


Write-Host
Write-Host "Start copying user Home Drives"
Write-Host

foreach ($user in $users) {

$source = "\\atlas\Public\home\" + $user.SAMAccountName
$dest = "\\er-apps01\er-data$\User Data\" + $user.SamAccountName
$logfile = "\\er-apps01\downloads$\DataMigrationLogs\User Data\User-" + $user.SAMAccountName + ".log"
$timestamp = get-date -Format MM-dd-yyyy-HHmmtt

Write-Host $timestamp " Start Copy - " $user.Name " - HomeDrive"

Robocopy $source $dest /B /E /DCOPY:T /COPY:DAT /MT /XF *.tmp *.*~ /W:1 /R:1 /FP /NP /L /LOG+:$logfile

}

Write-Host
Write-Host "Start copying user profiles"
Write-Host

foreach ($user in $users) {


$source = "\\atlas\Public\profiles\" + $user.SAMAccountName + ".V2"
$dest = "\\er-apps01\er-data$\User Profiles\" + $user.SamAccountName + ".V2"
$logfile = "\\er-apps01\downloads$\DataMigrationLogs\User Profiles\User-" + $user.SAMAccountName + ".log"
$timestamp = get-date -Format MM-dd-yyyy-HHmmtt

Write-Host $timestamp " Start Copy - " $user.Name " - V2 Profile"

Robocopy $source $dest /B /E /DCOPY:T /COPY:DAT /MT /XF *.tmp *.*~ /W:1 /R:1 /FP /NP /L /LOG+:$logfile

}
