$Box = 'Customer_Quotes'
ForEach($f in (Get-MailboxFolderStatistics $Box | Where { $_.FolderPath.Contains("/Inbox") -eq $True } ) )
{
$fname = $Box + ":" + $f.FolderPath.Replace("/","\"); Add-MailboxFolderPermission $fname -User tnowicki@linnproducts.net -AccessRights Owner
Write-Host $fname
Start-Sleep -Milliseconds 1000
}