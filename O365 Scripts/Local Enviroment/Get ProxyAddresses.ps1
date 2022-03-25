﻿Get-ADUser -Filter * -properties * | select-object name, samaccountname, surname, enabled, @{"name"="proxyaddresses";"expression"={$_.proxyaddresses}} | Export-Csv -Path C:\Users\admini\Desktop\proxyaddresses.csv