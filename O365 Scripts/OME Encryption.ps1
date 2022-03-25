﻿#Connect to the Azure Rights Management service. 
$cred = Get-Credential
Get-Command -Module aadrm
Connect-AadrmService -Credential $cred

#Activate the service.
Enable-Aadrm

#Get the configuration information needed for message encryption.
$rmsConfig = Get-AadrmConfiguration
$licenseUri = $rmsConfig.LicensingIntranetDistributionPointUrl

#Disconnect from the service.
Disconnect-AadrmService

#Create a remote PowerShell session and connect to Exchange Online.
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $session

#Collect IRM configuration for Office 365.
$irmConfig = Get-IRMConfiguration
$list = $irmConfig.LicensingLocation
if (!$list) { $list = @() }
if (!$list.Contains($licenseUri)) { $list += $licenseUri }

#Enable message encryption for Office 365.
Set-IRMConfiguration -LicensingLocation $list
Set-IRMConfiguration -AzureRMSLicensingEnabled $true -InternalLicensingEnabled $true

#Enable the Protect button in Outlook on the web (Optional).
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true

#Enable server decryption for Outlook on the web, Outlook for iOS, and Outlook for Android.
Set-IRMConfiguration -ClientAccessServerEnabled $true

#Test
Test-IRMConfiguration -Sender jloveall@justask.net

#Enable decryption of attachments
Set-IRMConfiguration -DecryptAttachmentFromPortal $true