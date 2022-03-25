$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
$hash=$null;$hash=@{};$mailboxes=get-mailbox;foreach($mailbox in $mailboxes) {$hash.add($mailbox.alias,(get-clutter -identity $mailbox.alias.tostring()).isenabled)};$hash | ft
#Disable All Users
#Get-Mailbox | ?{-not (Get-Clutter -Identity $_.Alias).IsEnabled} | %{Set-Clutter -Identity $_.Alias -Enable $false}
#Disable One User
#Set-Clutter -Identity CCombs@tricountytitle.biz -Enable $false

Connect-MsolService
Get-MsolUser –ReturnDeletedUsers | Remove-MsolUser –RemoveFromRecycleBin –Force
