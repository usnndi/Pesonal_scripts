<#
			"SatNaam WaheGuru"

Date: 03-03-2012, 00:15 Am
Author: Aman Dhally
Email:  amandhally@gmail.com
web:	www.amandhally.net/blog
blog:	http://newdelhipowershellusergroup.blogspot.com/
More Info : 

Version : 

	/^(o.o)^\ 


#>

# This Script Check the Status of Shell Hardware Detection
# If Script is STOPPED it START it and IF Script is RUNNING then it just say "Service in Sunning"
$A = get-service ShellHWDetection
if ($A.Status -eq "Stopped") {$A.start()} elseIf ($A.status -eq "Running") {Write-Host -ForegroundColor Yellow $A.name "is running"}