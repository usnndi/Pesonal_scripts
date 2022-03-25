#Clean up Schedulled Tasks
get-scheduledtask | where {$_.taskname -like "Optimize Start Menu Cache Files*"} | Unregister-ScheduledTask -Confirm:$false
get-scheduledtask | where {$_.taskname -like "G2MUpdateTask*"} | Unregister-ScheduledTask -Confirm:$false
get-scheduledtask | where {$_.taskname -like "G2MUploadTask*"} | Unregister-ScheduledTask -Confirm:$false
get-scheduledtask | where {$_.taskname -like "Dropbox*"} | Unregister-ScheduledTask -Confirm:$false

#Clean Temp Directory
Set-Location “C:\Windows\Temp”
Remove-Item * -recurse -force

#Remove Prefetch Files
Set-Location “C:\Windows\Prefetch”
Remove-Item * -recurse -force

##Remove Users Local temp Files
Set-Location “C:\Documents and Settings”
Remove-Item “.\*\Local Settings\temp\*” -recurse -force

#Remove Users Local temp Files
Set-Location “C:\Users”
Remove-Item “.\*\Appdata\Local\Temp\*” -recurse -force

#Stop Print Spooler
Stop-Service Spooler -Force

#Stop Spooler Process
Stop-Process -Name spoolsv -Force

#REM Delete all hung print jobs - also removes hung printers.
Remove-Item "C:\Windows\SYSTEM32\SPOOL\PRINTERS\*" -Force -Recurse

#REM Restart the Print Spooler
Start-Service -DisplayName 'Print Spooler'

#REM Restart Server
Shutdown /r /t 600