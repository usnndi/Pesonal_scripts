# This script compairs the contents of two directories and if the number of files 
# and their names are the same it zips the files in the logs directory and sends
# them to the ASK Proactive team. If the directories do not match, the ASK proactive
# team will receive a different email stating that their is an issue with the backup
# process.

# Define directory comparision variables:
$Directory_logs = Get-childitem -Name "E:\Saws_Backups\logs"
$Directory_logsPristine = Get-ChildItem -Name "E:\Saws_Backups\logsPristine"
$Directory_logsCount = Get-ChildItem "E:\Saws_Backups\logs" | Measure-Object

# Define Zip file variables:
$SourceZip = "E:\Saws_Backups\logs"
$DestinationZip = "E:\Saws_Backups\JAM_Retail_logs.zip"

#Define Email variables:
$EmailFrom = "sawsbackup@j-america.com"
$EmailTo = "cpontius@justask.net"
$EmailBodySuccess = "See attached log file for saws backup information."
$EmailBodyFailure = "Backup script failed. Diagnose and resolve the issue."
$EmailSubject = "J. America Sportswear Backup Logs"
$SMTPServer = "smtp.askhost247.com"
$SMTPPort = "25"


# Check if the logs directory has any files. If it does not, the result varable is listed as
# a string so it is not a null value
If($Directory_logsCount.count -eq 0){
$result = "Empty Directory"
}
# Check if the directory has any files, if it does, compare the logs and logsPristine directory.
# This either sets the result to a null value or delivers outut to the result variable.
If($Directory_logsCount.count -ne 0){
$result = Compare-Object $Directory_logs $Directory_logsPristine -Property Name
}

# Deturmine if the result of the compare is a null value. If it is, then the backup
# script was able to finish. Since it was able to finish, an email will be sent with
# the logs files attached as a zip file to the ASK proactive team.
If (!$result){
Write-Host "The Directories are the same"

# Create ZIP file of logs
Write-Host "Creating Zip file"
If(Test-path $DestinationZip) {Remove-item $DestinationZip}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($SourceZip, $DestinationZip)

# Send email to ASK Proactive Team
Write-Host "Creating Success Email"
$Message = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo, $EmailSubject, $EmailBodySuccess)
Write-Host "Attaching Zip file"
$Attachment = New-Object Net.Mail.Attachment($DestinationZip)
$Message.Attachments.Add($Attachment)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort)
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("justask", "YU5WS4edR42*yt"); 
Write-Host "Sending Success Email"

$SMTPClient.Send($Message)
# Close and dispose of the SMTP session
$Message.dispose()

#Remove backup log files and Zip File
Write-Host "Deleting log files"
Remove-item $DestinationZip
Get-ChildItem -Path E:\Saws_Backups\logs -Include *.* -File -Recurse | foreach { $_.Delete()}
}

# Deturmine if the file comparison has any output. If it does, it means that part of the backup script did not run correctly.
# If this is the case then an email will be sent to the ASK Proactive team 
If ($result){
Write-Host "The Directories are different"

#Send Email to ASK Proactive Team notifying them of a backup issue.
Write-Host "Creating Failure Email"
$Message = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo, $EmailSubject, $EmailBodyFailure)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort)
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("justask", "YU5WS4edR42*yt"); 
Write-Host "Sending Failure Email"
$SMTPClient.Send($Message)
# Close and dispose of the SMTP session
$Message.dispose()

}