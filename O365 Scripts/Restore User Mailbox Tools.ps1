#Connect to O365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Connect to Azure AD
Connect-MsolService

#Copy Mailbox to Mailbox. Source Box must be in Recyclebin
New-MailboxRestoreRequest -SourceMailbox 9495f4b1-bb5a-41ad-a495-620c5d0cbb16 -TargetMailbox  2214fc8e-5f44-483f-86b0-9c73b40ab6f8 -AllowLegacyDNMismatch

#Get Copy Status
Get-MailboxRestoreRequest

#Alternate Mailbox Restore
Restore-MsolUser -AutoReconcileProxyConflicts -UserPrincipalName "amis@mbcloans.biz"

#FL = Full List
Get-MsolUser -UserPrincipalName "" | FL

#FL = Full List
Get-Mailbox -Identity aschock1@mbcloans.biz | FL

Get-Mailbox -Identity "jloveall@justask.net" | FL Name,Identity,LitigationHoldEnabled,InPlaceholds,WhenSoftDeleted,IsInactiveMailbox,wWWHomePage, GUID

Set-Mailbox -Identity "amis@mbcloans.biz" -LitigationHoldEnabled $true -InactiveMailbox

#Restore AD Account
Restore-MsolUser -ObjectId b5b7f25c-171b-4d0f-b435-d1ff1b47861c

#get-mailbox | Set-MailboxRegionalConfiguration -Language 1033 -TimeZone 035

#Delete Users
remove-msoluser -userprincipalname amis@mbcloans.biz -removefromrecyclebin -force
Get-Recipient -ResultSize Unlimited | ? {$_.EmailAddresses -like “amis@mbcloans.biz”}

$immutableID = [System.Convert]::ToBase64String($guid.tobytearray())

TOF13GR9T0ClE750J5xbFQ==

Set-MsolUser -UserPrincipalName amis1@mbcloans.biz -ImmutableId

Start-Transcript
Get-Recipient -Identity amis@mbcloans.biz
get-msoluser -UserPrincipalName amis@mbcloans.biz 
Get-Mailbox -Identity amis@mbcloans.biz
get-msoluser -ReturnDeletedUsers 
Get-Mailbox -SoftDeletedMailbox 
Get-MailUser -SoftDeletedMailUser 
Get-Recipient -resultsize unlimited | where {$_.EmailAddresses -match "amis@mbcloans.biz"} | fL Name, RecipientType,emailaddresses

Connect-AzureAD
Set-AzureADUser -ObjectId dfredrick@justask.net -UserPrincipalName dfrederick@justask.net

$UserId = (Get-AzureADUser -Searchstring ssimmon@justask.net).ObjectId

(Get-AzureADUser -Searchstring ssimmon@justask.net).ObjectId

(Get-AzureADUserExtension -Searchstring jloveall@justask.net).get_item("wWWHomePage")

(Get-AzureADUser -Searchstring jloveall@justask.net).ToJson()
(Get-AzureADUser -ObjectId 031e272e-e401-4f1d-b48e-0f48c6c588e1).ToJson()