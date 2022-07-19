$appToFind = "Remote Desktop"

function Write-Log {
    # Writes to a log file in a SCCM/MECM friendly format
    param(
        [String]$message,
        [int]$severity,
        [string]$component
    )
    $timeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone"
    $date = Get-Date -Format "HH:mm:ss.fff"
    $date2 = Get-Date -Format "MM-dd-yyyy"
    $date3 = Get-Date -Format "yyyy-MM-dd"

    # Set defaults if not specified
    if (!($logName)) { $logName = "PowerShell" }
    if (!($logLocation)) { $logLocation = "$env:temp" }  #

    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($timeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>" | Out-File -FilePath "$logLocation\$logName-$date3.Log" -Append -NoClobber -Encoding default}

function Get-InstalledApps {
    param()
    begin {}
    process {
        # Get x86 applications
        $apps = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Select-Object DisplayName, 
        DisplayVersion, 
        UninstallString,
        InstallDate,
        @{Name = "AppArchitecture"; Expression = { "86" } }
        # If it is x64, then also include the wow6432Node
        if ((Get-WmiObject Win32_Processor).AddressWidth -eq 64) {
            $apps += Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
            Select-Object DisplayName,
            DisplayVersion, 
            UnInstallString,
            InstallDate, 
            @{Name = "AppArchitecture"; Expression = { "64" } }
        }
        # Output apps with a display name
        $apps | Where-Object { !([string]::IsNullOrEmpty($_.DisplayName)) }
    }
    end {}
}


# Get all 32\64 bit applications
Write-Log -message "Getting installed apps" -severity 1 -component "RemoveApp"
$installedApps = Get-InstalledApps
Write-Log -message "$($installedApps.count) applications found" -severity 1 -component "RemoveApp"
Write-Log -message "Looking for $appToFind" -severity 1 -component "RemoveApp"

# Filter results by the app we're looking for
$results = $installedApps | Where-Object { $_.DisplayName -match $appToFind}

# If an application was found...
if ($results) {
    foreach ($application in $results) {
        Write-Log -message "Uninstalling $($application.DisplayName) ($($application.UninstallString))" -severity 1 -component "RemoveApp"
        # If the uninstall string exists for the app
        If ($application.UninstallString) {
            $uninstallString = $application.UninstallString
            # If it's an MSI then we want to make sure it launches quietly, and logs to the same location as our log
            if (($application.UninstallString).StartsWith("MsiExec.exe")) {
                Write-Log -message "Detected MSI" -severity 1 -component "RemoveApp"
                $uninstallString = "$($application.UninstallString) /qn /norestart /log $($env:temp)\$($application.DisplayName).log"
            }
            Write-Log -message "Running Command: $uninstallString" -severity 1 -component "RemoveApp"
            # Run the uninstall command and log to variable so we can extract the exit code
            $process = (Start-Process -FilePath "cmd.exe" -ArgumentList '/c', $application.UninstallString -wait -PassThru -WindowStyle Hidden)
            if ($process.ExitCode -ne 0) {
                # If the process failed (not error code 0)
                $exitCode = $process.ExitCode
                Write-Log -message "Command completed with exit code: $($process.ExitCode)" -severity 3 -component "RemoveApp"
            } else {
                # If the process completed successfully (error code 0)
                Write-Log -message "Command completed with exit code: $($process.ExitCode)" -severity 1 -component "RemoveApp"
            }
        } else {
            # The application was found, but no uninstall sting was found (error 1)
            Write-Log -message "There is no uninstall string for $($application.DisplayName)" -severity 3 -component "RemoveApp"
            $exitCode = 3
        } 
    }
} else {
    # Application wasn't found - most likely wasn't installed, so technically this was a success but will log as a warning
    Write-Log -message "$appToFind is not installed, or doesn't have a registered uninstall method." -severity 2 -component "RemoveApp"
    $exitCode = 0
}

exit $exitCode