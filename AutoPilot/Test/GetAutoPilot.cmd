REM Download this powershell script and inclde with this cmd file - https://www.powershellgallery.com/packages/Get-WindowsAutoPilotInfo/1.6
REM This needs winrm running on an existing system : winrm quickconfig 

winrm quickconfig || PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command %~d0\Get-WindowsAutoPilotInfo.ps1 -ComputerName $env:computername -OutputFile %~d0\computers.csv -append
