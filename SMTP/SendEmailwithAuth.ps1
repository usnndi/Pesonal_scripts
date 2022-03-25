$emailusername = "justask"
$encrypted = Get-Content C:\SQLJobs\DailyEmailPW.txt | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($emailusername, $encrypted)

Send-MailMessage -From 'askapp01@justask.net' -To 'jloveall@justask.net' -Subject 'DB SSI Update' -Body 'Job run successful!!' -SmtpServer 'smtp.askhost247.com' -Credential $credential