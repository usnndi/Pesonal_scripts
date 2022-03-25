Write-Host "Starting up the AutoCad WOrkstation, please stand by"
#Start Azure WS01 VM
Invoke-WebRequest -Uri http://example.com/foobar -Method POST
#Wait Until VM Starts
Write-Host "Waiting 3 minutes until it is ready"
Start-Sleep -Seconds 180