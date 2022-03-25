#Connect to O365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Define O365 Group Owner
$adminUPN="jloveall@justask.net"

#Define Org Name Site Name
$orgName="justask"

#Grab Password to Auth
$usercredential = Get-Credential -username $adminUPN -Message "type password"

#Connect to Sharepoint Online O365 Group
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential

#Define O365 Group
$siteurl="https://$orgName.sharepoint.com/sites/ProjectServices"

#Set Perms for Group
set-sposite -identity $Siteurl -sharingcapability ExternalUserAndGuestSharing