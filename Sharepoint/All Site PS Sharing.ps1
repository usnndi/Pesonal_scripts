$adminUPN="admin@elevatemarketing.onmicrosoft.com"
$orgName="elevatemarketing"
$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential

Set-SPOSite -Identity https://elevatemarketing.sharepoint.com/sites/ElevateCreativeTeam -SharingCapability ExternalUserAndGuestSharing