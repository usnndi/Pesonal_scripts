$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session



Get-UnifiedGroup -Identity "Project Service Group" | FL

Set-UnifiedGroup -Identity "All ASK" -PrimarySmtpAddress allask@justask.net -RequireSenderAuthenticationEnabled $true