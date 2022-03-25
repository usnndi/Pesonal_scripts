<# 
    Set some variables
    ...
#>
$emailusername = "myemail"
$encrypted = Get-Content c:\scripts\encrypted_password.txt | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($emailusername, $encrypted)

if($something = $somethingElse)
{
    <#
        Do some stuff
        ...
    #>

    $EmailFrom = "myemail@gmail.com"
    $EmailTo = "myemail+alerts@gmail.com"
    $Subject = "I did some stuff!" 
    $Body = "This is a notification from Powershell." 
    $SMTPServer = "smtp.gmail.com" 
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = $credential;
    $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}