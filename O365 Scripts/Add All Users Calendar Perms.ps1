$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$allUsers = Get-Mailbox | Select Identity

ForEach ( $user in $allUsers ) {

    Get-Mailbox | ForEach { 

        If ( $_.Identity -ne $user.Identity ) {

            Add-MailboxFolderPermission "$($_.SamAccountName):\calendar" -User $user.Identity -AccessRights  PublishingEditor
        }
    
    }

}