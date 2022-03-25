#Login
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

##All Mailboxes
$UserMailboxes = Get-Mailbox | Where {$_.RecipientTypeDetails -eq “UserMailbox”}
$UserMailboxes | Add-RecipientPermission -AccessRights SendAs –Trustee scans@wielandbuilds.com

#One Mailbox
#Add-RecipientPermission jlucas@wielandbuilds.com -AccessRights SendAs -Trustee scans@wielandbuilds.com