#install aadrm module

Connect-AadrmService
Connect-ExchangeOnline

# Activate the service
Enable-Aadrm

# Get the configuration information needed for message protection.
$rmsConfig = Get-AadrmConfiguration
$licenseUri = $rmsConfig.LicensingIntranetDistributionPointUrl

# Collect IRM configuration for Office 365.
$irmConfig = Get-IRMConfiguration
$list = $irmConfig.LicensingLocation
if (!$list) { $list = @() }
if (!$list.Contains($licenseUri)) { $list += $licenseUri }

# Enable message protection for Office 365.
Set-IRMConfiguration -LicensingLocation $list
Set-IRMConfiguration -AzureRMSLicensingEnabled $True -InternalLicensingEnabled $true
Set-IRMConfiguration -SimplifiedClientAccessEnabled $true

#Verify Setting
Get-IRMConfiguration

Test-IRMConfiguration -Sender ttran@perfectaire.us