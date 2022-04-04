Start-Transcript -Path C:\CNWI\Scripts\ADPWExpiration\ADPWETranscript.log -Append
#################################################################################################################
#
# Password-Expiration-Notifications v20180412
# Highly Modified fork. https://gist.github.com/meoso/3488ef8e9c77d2beccfd921f991faa64
#
# Originally from v1.4 @ https://gallery.technet.microsoft.com/Password-Expiry-Email-177c3e27
# Robert Pearman (WSSMB MVP)
# TitleRequired.com
# Script to Automated Email Reminders when Users Passwords due to Expire.
#
# Requires: Windows PowerShell Module for Active Directory
#
##################################################################################################################
# Please Configure the following variables....
$SearchBase="OU=Users,OU=Wilcox & Flegel,DC=WilcoxandFlegel,DC=local"
$smtpServer="wilcoxandflegel-com.mail.protection.outlook.com"
$expireindays = 5 #number of days of soon-to-expire paswords. i.e. notify for expiring in X days (and every day until $negativedays)
$negativedays = -3 #negative number of days (days already-expired). i.e. notify for expired X days ago
$from = "helpdesk@wilcoxandflegel.com"
$logging = $true # Set to $false to Disable Logging
$logNonExpiring = $false
$logFile = "C:\CNWI\Scripts\ADPWExpiration\PS-pwd-expiry.csv" # ie. c:\mylog.csv
$testing = $true # Set to $false to Email Users
$adminEmailAddr = "jloveall@justask.net"#,"zDavis@wilcoxandflegel.com"#Admin2@example.com","Admin3@example.com" #multiple addr allowed but MUST be independent strings separated by comma
$sampleEmails = 1 #number of sample email to send to adminEmailAddr when testing ; in the form $sampleEmails="ALL" or $sampleEmails=[0..X] e.g. $sampleEmails=0 or $sampleEmails=3 or $sampleEmails="all" are all valid.
#
###################################################################################################################

# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format yyyy-MM-dd

$starttime=Get-Date #need time also; don't use date from above

Write-Host "Processing `"$SearchBase`" for Password-Expiration-Notifications"

#set max sampleEmails to send to $adminEmailAddr
if ( $sampleEmails -isNot [int]) {
    if ( $sampleEmails.ToLower() -eq "all") {
    $sampleEmails=$users.Count
    } #else use the value given
}

if (($testing -eq $true) -and ($sampleEmails -ge 0)) {
    Write-Host "Testing only; $sampleEmails email samples will be sent to $adminEmailAddr"
} elseif (($testing -eq $true) -and ($sampleEmails -eq 0)) {
    Write-Host "Testing only; emails will NOT be sent"
}

# Create CSV Log
if ($logging -eq $true) {
    #Always purge old CSV file
    Out-File $logfile
    Add-Content $logfile "`"Date`",`"SAMAccountName`",`"DisplayName`",`"Created`",`"PasswordSet`",`"DaystoExpire`",`"ExpiresOn`",`"EmailAddress`",`"Notified`""
}

# Get Users From AD who are Enabled, Passwords Expire
Import-Module ActiveDirectory
$users = get-aduser -SearchBase $SearchBase -Filter {(enabled -eq $true) -and (passwordNeverExpires -eq $false)} -properties sAMAccountName, displayName, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress, lastLogon, whenCreated
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

$countprocessed=${users}.Count
$samplesSent=0
$countsent=0
$countnotsent=0
$countfailed=0

# Process Each User for Password Expiry
foreach ($user in $users) {
    $dName = $user.displayName
    $sName = $user.sAMAccountName
    $emailaddress = $user.emailaddress
    $whencreated = $user.whencreated
    $passwordSetDate = $user.PasswordLastSet
    $sent = "" # Reset Sent Flag

    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null) {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    } else {
        # No FGPP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }

    #If maxPasswordAge=0 then same as passwordNeverExpires, but PasswordCannotExpire bit is not set
    if ($maxPasswordAge -eq 0) {
        Write-Host "$sName MaxPasswordAge = $maxPasswordAge (i.e. PasswordNeverExpires) but bit not set."
    }

    $expiresOn = $passwordsetdate + $maxPasswordAge
    $today = (get-date)

    if ( ($user.passwordexpired -eq $false) -and ($maxPasswordAge -ne 0) ) {   #not Expired and not PasswordNeverExpires
		$daystoexpire = (New-TimeSpan -Start $today -End $expiresOn).Days
    } elseif ( ($user.passwordexpired -eq $true) -and ($passwordSetDate -ne $null) -and ($maxPasswordAge -ne 0) ) {   #if expired and passwordSetDate exists and not PasswordNeverExpires
        # i.e. already expired
    	$daystoexpire = -((New-TimeSpan -Start $expiresOn -End $today).Days)
    } else {
        # i.e. (passwordSetDate = never) OR (maxPasswordAge = 0)
    	$daystoexpire="NA"
        #continue #"continue" would skip user, but bypass any non-expiry logging
    }

    #Write-Host "$sName DtE: $daystoexpire MPA: $maxPasswordAge" #debug

    # Set verbiage based on Number of Days to Expiry.
    Switch ($daystoexpire) {
        {$_ -ge $negativedays -and $_ -le "-1"} {$messageDays = "has expired"}
        "0" {$messageDays = "will expire today"}
        "1" {$messageDays = "will expire in 1 day"}
        default {$messageDays = "will expire in " + "$daystoexpire" + " days"}
    }
#########################################################################################################################################################################
# Email Body Set Here, Note You can use HTML, including Images.
    #$body="
    #<p>Your Active Directory password for your <b>$sName</b> account $messageDays.  After expired, you will not be able to login until your password is changed.</p>
    #<p>Please visit selfservice.example.com to change your password.  Alternatively, on a Windows machine, you may press Ctrl-Alt-Del and select `"Change Password`".</p>
    #<p>If you do not know your current password, <a href='https://selfservice.example.com/?action=sendtoken'>click here to email a password reset link</a>.</p>
    #<p>Thank you,<br>
    #Example.com Administrator<br>
    #Administrator@example.com<br>
    #www.example.com/support/<br>
    #</p>
    #"
##########################################################################################################################################################################
    # Email Subject Set Here
    $subject="Your password $messageDays"
    #Message Body SDet Here
    $Body ="
<p>$displayname,</p>
<p>Your Windows password for your account <b>$sname</b>, will expire in $messageDays. After it expires, you will not be able to log in until your password is changed.</p>
<ol>
<li>Please visit <a href='https://rds.wilcoxandflegel.com/RDWeb'>https://rds.wilcoxandflegel.com/RDWeb</a> to change your password.</li>
<li>In the Domain\username: field enter WILCOXANDFLEGEL\&lt;username&gt;
<ol>
<li>e.g. wilcoxandflegel\jSmith</li>
</ol>
</li>
<li>Enter your current password</li>
<li>Enter your new password</li>
<li>Confirm your new password</li>
<li>Click SUBMIT&nbsp;</li>
</ol>
<p>Alternatively, you may press Ctrl-Alt-Del on a Windows machine and select Change Password.</p>
<p>Thank you,</p>
<p>Wilcox + Flegel Helpdesk<br />
<a href='mailto:Helpdesk@wilcoxandflegel.com'>Helpdesk@wilcoxandflegel.com</a>
<br />360-957-2127<br />
<img src='https://www.wilcoxandflegel.com/wp-content/uploads/2020/04/cropped-WilcoxFavicon-192x192.png' width='70' height='70' /></p>
"

    #If testing-enabled and send-samples, then set recipient to adminEmailAddr else user's EmailAddress
    if (($testing -eq $true) -and ($samplesSent -lt $sampleEmails)) {
        $recipient = $adminEmailAddr
    } else {
        $recipient = $emailaddress
    }

    #if in trigger range, send email
    if ( ($daystoexpire -ge $negativedays) -and ($daystoexpire -lt $expireindays) -and ($daystoexpire -ne "NA") ) {
        # Send Email Message
        if (($emailaddress) -ne $null) {
            if ( ($testing -eq $false) -or (($testing -eq $true) -and ($samplesSent -lt $sampleEmails)) ) {
                try {
                    Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop -ErrorVariable err
                } catch {
                    write-host "Error: Could not send email to $recipient via $smtpServer"
                    $sent = "Send fail"
                    $countfailed++
                } finally {
                    if ($err.Count -eq 0) {
                        write-host "Sent email for $sName to $recipient"
                        $countsent++
                        if ($testing -eq $true) {
                            $samplesSent++
                            $sent = "toAdmin"
                        } else { $sent = "Yes" }
                    }
                }
            } else {
                Write-Host "Testing mode: skipping email to $recipient"
                $sent = "No"
                $countnotsent++
            }
        } else {
            Write-Host "$dName ($sName) has no email address."
            $sent = "No addr"
            $countnotsent++
        }

        # If Logging is Enabled Log Details
        if ($logging -eq $true) {
            Add-Content $logfile "`"$date`",`"$sName`",`"$dName`",`"$whencreated`",`"$passwordSetDate`",`"$daystoExpire`",`"$expireson`",`"$emailaddress`",`"$sent`""
        }
    } else {
        #if ( ($daystoexpire -eq "NA") -and ($maxPasswordAge -eq 0) ) { Write-Host "$sName PasswordNeverExpires" } elseif ($daystoexpire -eq "NA") { Write-Host "$sName PasswordNeverSet" } #debug
        # Log Non Expiring Password
        if ( ($logging -eq $true) -and ($logNonExpiring -eq $true) ) {
            if ($maxPasswordAge -eq 0 ) {
                $sent = "NeverExp"
            } else {
                $sent = "No"
            }
            Add-Content $logfile "`"$date`",`"$sName`",`"$dName`",`"$whencreated`",`"$passwordSetDate`",`"$daystoExpire`",`"$expireson`",`"$emailaddress`",`"$sent`""
        }
    }

} # End User Processing

$endtime=Get-Date
$totaltime=($endtime-$starttime).TotalSeconds
$minutes="{0:N0}" -f ($totaltime/60)
$seconds="{0:N0}" -f ($totaltime%60)

Write-Host "$countprocessed Users from `"$SearchBase`" Processed in $minutes minutes $seconds seconds."
Write-Host "Email trigger range from $negativedays (past) to $expireindays (upcoming) days of user's password expiry date."
Write-Host "$countsent Emails Sent."
Write-Host "$countnotsent Emails skipped."
Write-Host "$countfailed Emails failed."

if ($logging -eq $true) {
    #sort the CSV file
    Rename-Item $logfile "$logfile.old"
    import-csv "$logfile.old" | sort ExpiresOn | export-csv $logfile -NoTypeInformation
    Remove-Item "$logFile.old"
    Write-Host "CSV File created at ${logfile}."

    #email the CSV and stats to admin(s) 
    if ($testing -eq $true) {
        $body="<b><i>Testing Mode.</i></b><br>"
    } else {
        $body=""
    }

    $body+="
    CSV Attached for $date<br>
    $countprocessed Users from `"$SearchBase`" Processed in $minutes minutes $seconds seconds.<br>
    Email trigger range from $negativedays (past) to $expireindays (upcoming) days of user's password expiry date.<br>
    $countsent Emails Sent.<br>
    $countnotsent Emails skipped.<br>
    $countfailed Emails failed.
    "

    try {
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $adminEmailAddr -subject "Password Expiry Logs" -body $body -bodyasHTML -Attachments "$logFile" -priority High -Encoding $textEncoding -ErrorAction Stop -ErrorVariable err
    } catch {
         write-host "Error: Failed to email CSV log to $adminEmailAddr via $smtpServer"
    } finally {
        if ($err.Count -eq 0) {
            write-host "CSV emailed to $adminEmailAddr"
        }
    }
}
Stop-Transcript
# End