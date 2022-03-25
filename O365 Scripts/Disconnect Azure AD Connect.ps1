Connect-MSOLservice
$IsDirSyncEnabled = (Get-MsolCompanyInformation).DirectorySynchronizationEnabled
If($IsDirSyncEnabled -eq $True) {
    Write-Host "Disabling Active Directory " 
    Set-MsolDirSyncEnabled -EnableDirSync $false -force
    Write-Host "Waiting for propagation " -NoNewline
    #waiting five seconds for propagation
    foreach ($i in 1..5) { 
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline
    }
    Write-Host " - Good to go!" 
}