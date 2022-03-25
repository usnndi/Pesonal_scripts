Connect-ExchangeOnline
Set-OrganizationConfig -AutoExpandingArchive
Get-Mailbox -ResultSize Unlimited | Enable-Mailbox -Archive

$Mailboxes = Get-Mailbox -ResultSize Unlimited # -Filter {RecipientTypeDetails -eq "UserMailbox"}
$Mailboxes.Identity | Start-ManagedFolderAssistant
