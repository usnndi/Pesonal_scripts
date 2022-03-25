Get-PhysicalDisk | ? {“Serial Number”.Contains($_.SerialNumber)} | Set-PhysicalDisk -NewFriendlyName "New Name"
