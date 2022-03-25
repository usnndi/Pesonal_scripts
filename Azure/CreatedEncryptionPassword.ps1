<# Set and encrypt credentials to file using default method #>

$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content C:\Users\jloveall\Desktop\encrypted_password1.txt
