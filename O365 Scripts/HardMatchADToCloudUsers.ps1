<#
====================================================================================================================================================
 THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT
 WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
 FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR 
 RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
====================================================================================================================================================

Created by: Hector
Email: hventura@aceitconsultinginc.com

USE:
HARD MATCH AD USERS TO CLOUD USERS.
NEED TO BE RAN IN A SERVER WITH ACTIVE DIRECTORY, MSONLINE AND OFFICE 365 POWERSHELL MODULES INSTALLED

NOTE:
DURING THIS PROCEDURE, DIRSYNC IS DISABLE, AND RE-ENABLE. THE RE-ENABLE PROCESS CAN TAKE UP TO 72 HOURS.
IN MY EXPERIENCE, DIRSYNC CAN BE RE-ENABLED IN LESS TIME SO THIS PROGRAM CAN KEEP TRYING EVERY 15 MINUTES
UNTIL DIRSYNC BE FINALLY ENABLED.

Instructions:
1 - This program has to be ran in a Windows Server 2008, 2012 or 2016
2 - Run PowerShell as administrator
3 - If the server is not a DC, run the following command to install the AD powershell module
     Install-WindowsFeature RSAT-AD-PowerShell
4 - Run the following commands install Powershell for Office 365 in the server
    Install-Module AzureAD -force
    Install-Module MsOnline -force
#>


Install-Module msonline
Install-Module ExchangeOnlineManagement

# Import the necessary modules
Import-Module ActiveDirectory
#Import-Module msoline

#Connect to Office 365
$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MSOLservice -Credential $livecred


#Verify Active Directory Sync Has Been Disabled
$IsDirSyncEnabled = (Get-MsolCompanyInformation).DirectorySynchronizationEnabled
If($IsDirSyncEnabled -eq $True) {
    Write-Host "Disabling Active Directory " 
    Set-MsolDirSyncEnabled -EnableDirSync $false -force
    Write-Host "Waiting for propagation " -NoNewline
    #waiting five seconds for propagation
    foreach ($i in 1..5) { 
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline
    }
    Write-Host " - Good to go!" 
} 

#Exporting your existing AD users list. This command failed if program is not in a DC. But it doesn't# affect the hard match. this is only to make a list of the AD users and their Guidsldifde -f C:\export.txt -r "(Userprincipalname=*)" -l "objectGuid, userPrincipalName"Write-host "Backup of UserPrincipalName and objectGuid made to C:\export.txt" -BackgroundColor Blue

###Careful### The following commands are to purge all the deleted users and mailboxes from the recycle bins on Office 365
###Uncomment the next two lines if you are getting conflicts with deleted users and mailboxes
### Users and mailboxes deleted cannot be recovered.
# Get-MsolUser -ReturnDeletedUsers | Remove-MsolUser -RemoveFromRecycleBin -Force# Get-Mailbox -SoftDeleted | % { Remove-mailbox -Identity  ($_.ExchangeGuid.tostring()) -PermanentlyDelete -Confirm:$false }

$ADUsers = Get-ADUser -Filter *
#$MSOLUsers = Get-MsolUser

do{ 
    # Query the local AD and get all the users output to grid for selection     $ADGuidUser = $ADUsers | Select Name,ObjectGUID | Sort-Object Name | Out-GridView -Title "Select Local AD User To Get Immutable ID for" -PassThru 
    #Convert the GUID to the Immutable ID format 
    $UserimmutableID = [System.Convert]::ToBase64String($ADGuidUser.ObjectGUID.tobytearray())

    # Query the existing users on Office 365 and output to grid for selection 
    $OnlineUser = Get-MsolUser | Select UserPrincipalName,DisplayName,ProxyAddresses,ImmutableID | Sort-Object DisplayName | Out-GridView -Title "Select The Office 365 Online User To HardLink The AD User To" -PassThru

    #Command that sets the office 365 user you picked with the OnPrem AD ImmutableID     if ($ADGuidUser -and $OnlineUser) {
        Set-MSOLuser -UserPrincipalName $OnlineUser.UserPrincipalName -ImmutableID $UserimmutableID

        #Verify ImmutableID has been updated         $Office365UserQuery = Get-MsolUser -UserPrincipalName $OnlineUser.UserPrincipalName | Select DisplayName,ImmutableId
        Write-Host "Do the ID's Match? if not something is wrong" 
        Write-Host "AD Immutable ID Used" $UserimmutableID
        Write-Host "Office365 UserLinked" $Office365UserQuery.ImmutableId    }

    # Ask To Repeat The Script 
    $Repeat = read-host "Do you want to choose another user? Y or N"
} while ($Repeat -eq "Y")

#Verify Active Directory Sync re-enabling 
$Repeat = "N"
$Continuetrying = $False
$IsDirSyncEnabled = (Get-MsolCompanyInformation).DirectorySynchronizationEnabled
do {
    if ($IsDirSyncEnabled -eq $False) {
        Write-Host "Enabling Active Directory " -NoNewline;
        try {
            Set-MsolDirSyncEnabled -EnableDirSync $true -Force -ErrorAction Stop;
            Write-Host " - Done" 
        }
        Catch {
            "`nDirectory Synchronization couldn't be re-enabled."
        }
    }
    $IsDirSyncEnabled = (Get-MsolCompanyInformation).DirectorySynchronizationEnabled
    if ($IsDirSyncEnabled -eq $False) {
        If ($Continuetrying -eq $False) {
            $Repeat = read-host "Do you want this program continues trying every 15 minutes (y/n)?"
            if ($Repeat -eq "Y") { $Continuetrying = $True }
        }
    }
    else { 
        write-host "Dirsync was successfuly enabled."
        $Continuetrying = $false 
    }
    if ($Continuetrying -eq $True) { 
        write-host "Waiting 15 minutes to try again"
        Start-Sleep -Seconds 900 
        #Start-Sleep -Seconds 5
    }
} while(($Continuetrying -eq $True) -and ($Repeat = "Y"))
write-host " --------- DONE ------------- "
##### END PROGRAM ###########
