$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
#Primary PF
#Update-PublicFolderMailbox -Identity 'PublicFolderMailbox EX1UP6' -FullSync -InvokeSynchronizer
#Auto Split PF
#Update-PublicFolderMailbox -Identity 'AutoSplit_b94d4c28ef6f41e88873c7e2edd31bdf' -FullSync -InvokeSynchronizer
#Secondary PF Mailbox
#Update-PublicFolderMailbox -Identity 'PublicFolderMailbox YH9YK4' -FullSync -InvokeSynchronizer
