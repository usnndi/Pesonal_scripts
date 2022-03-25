$oldDomain = "olddomaname.tld"
$newDomain = "newdomainname.tld"
$userou = 'OU=TestOU,DC=domain,DC=com'
 
$users = Get-ADUser -Filter * -SearchBase $userou -Properties SamAccountName, EmailAddress, ProxyAddresses
 
Foreach ($user in $users) {
    $mailAttributeNull = $true
    $primaryProxyNull = $true
    $aliasProxyNull = $true
     
    $currentEmailAddress = $null
     
    $currentEmailName = $null
    $currentEmailDomain = $null
     
    $currentProxyType = $null
    $currentProxyEmail = $null
         
    $currentProxyName = $null
    $currentProxyDomain = $null
     
    $proxiesToRemove = @()
    $proxiesToAdd = @()
 
    Write-Host
    Write-Host "==================================================" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "User: $($user.samaccountname)" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "==================================================" -ForegroundColor White -BackgroundColor DarkBlue
     
    # ---------------------------------------
    # Update Mail Attribute  
    # ---------------------------------------
    Write-Host
    Write-Host "Updating Mail Attribute"
    Write-Host "----------------------------------------"
    $currentEmailAddress = $user.EmailAddress
     
    if ($currentEmailAddress) {
        Write-Host "   Current Email: " $currentEmailAddress
        $mailAttributeNull = $false
             
        $currentEmailName = $currentEmailAddress.Split("@")[0]
        $currentEmailDomain = $currentEmailAddress.Split("@")[1]
         
        If ($currentEmailDomain -ieq $oldDomain) {
            $newemail = -join($currentEmailName, "@",$newDomain)
            Write-Host "   New Email: " $newemail
             
            $user.EmailAddress = $newemail
        }
        Elseif ($currentEmailDomain -ieq $newDomain) {
            Write-Host "   Mail Attribute: New Value Detected Skipping..."
            Write-Host "   Value: $($user.EmailAddress)"
        }
        Else {
            Write-Host "   Not a domain we are interesting in, skipping..."
        }
    } else {
            $mailAttributeNull = $true
            Write-Host "   Mail Attribute: Empty  Skipping..."
    }
     
    # ---------------------------------------
    # Update Proxy Addresses  
    # ---------------------------------------
    Write-Host
    Write-Host "Updating Proxy Addresses"
    Write-Host "----------------------------------------"
     
    ForEach ($proxy in $user.ProxyAddresses) {
     
        Write-Host "  PROCESSING : " $proxy
        $currentProxyType = $proxy.Split(":")[0]  #Before the : SMTP or smtp
        $currentProxyEmail = $proxy.Split(":")[1] #After the : firstname.surenames@domain.tld
         
        $currentProxyName = $currentProxyEmail.Split("@")[0] #Before the @ firstname.surname
        $currentProxyDomain = $currentProxyEmail.Split("@")[1] #After the @ domain.tld
     
        If ($currentProxyType -ceq "SMTP") {
            # -------------------------------------
            #Process the primary address
            # -------------------------------------
            $primaryProxyNull = $false
             
            Write-Host "      ** PRIMARY (SMTP:)" -ForegroundColor White -BackgroundColor DarkGreen
             
            If ($currentProxyDomain -ieq $oldDomain) {
                # Found the primary proxy was on the old domain, change the primary to the new domain and move the old primary to an alias.
                Write-Host "      Its on the old domain, updating..."
                $newPrimaryProxy = -join("SMTP:", $currentProxyName, "@",$newDomain)
                $newAliasProxy = -join("smtp:", $currentProxyName, "@",$oldDomain)
                 
                Write-Host "         New Primary Proxy: " $newPrimaryProxy
                Write-Host "         New Alias Proxy: " $newAliasProxy
                 
                $proxiesToRemove += $proxy
                $proxiesToAdd += $newPrimaryProxy
                $proxiesToAdd += $newAliasProxy
                 
            } elseif ($currentProxyDomain -ieq $newDomain) {
                    Write-Host "      Already on the new domain, skipping..."          
            } else {
                    Write-Host "      Not a domain we are interesting in, skipping..."
            }
        } elseif ($currentProxyType -ceq "smtp") {
            # -------------------------------------
            #Process the alias addresses
            # -------------------------------------
            $aliasProxyNull = $false
             
            Write-Host "      * Alias (smtp:)"
             
            If ($currentProxyDomain -ieq $oldDomain) {
                # Found the alias proxy was on the old domain, change the alias to the new domain and move the old alias to an alias.
                Write-Host "      On the old domain, adding a copy on the new domain..."
                $newAliasProxy = -join("smtp:", $currentProxyName, "@",$newDomain)
                 
                Write-Host "         New Alias Proxy: " $newAliasProxy
                $proxiesToAdd += $newAliasProxy
                 
            } elseif ($currentProxyDomain -ieq $newDomain) {                
                #Check is this is a duplicate of the new primary proxy
                $currentDuplicateProxyCheck = -join("SMTP:", $currentProxyEmail)
                     
                if ($currentProxyEmail -ieq $newemail)
                {
                    #This is a duplicate of the primary address so will remove it
                    Write-Host "      This is a duplicate of the primary address so will remove it"
                    $proxiesToRemove += $proxy
                }
                     
                    Write-Host "      Already on the new domain, skipping..."  
            } else {
                    Write-Host "      Not a domain we are interesting in, skipping..."
            }
        }
 
    }
     
    #Deal with there not being a proxy address
    if ($primaryProxyNull -eq $true -And $mailAttributeNull -eq $false) {
        #Proxy is empty but mail has a value
        Write-Host "   No proxy addresses set, setting up..."
             
        $newPrimaryProxy = -join("SMTP:", $currentEmailName, "@",$newDomain)
        $newAliasProxy = -join("smtp:", $currentEmailName, "@",$oldDomain)
             
        Write-Host "      New Primary Proxy: " $newPrimaryProxy
        Write-Host "      New Alias Proxy: " $newAliasProxy
             
        $proxiesToAdd += $newPrimaryProxy
        $proxiesToAdd += $newAliasProxy
         
    } elseif ($primaryProxyNull -eq $true-And $mailAttributeNull -eq $true) {
        Write-Host "   The user does not have a mail attribute or any proxy addresses, skipping user..."  -ForegroundColor White -BackgroundColor DarkRed
    }
     
    # -------------------------------------
    # Submit changes
    # -------------------------------------
    Write-Host
    Write-Host "Proxy Changes Made"
    Write-Host "----------------------------------------"
     
    #Removals
    foreach($removeProxy in $proxiesToRemove) {
 
        Write-Host "   Removed " $removeProxy
        $user.ProxyAddresses.remove($removeProxy)
    }
     
    # Additions
    foreach($addProxy in $proxiesToAdd) {
 
        Write-Host "   Added " $addProxy
        $user.ProxyAddresses.add($addProxy)
    }
     
    # -------------------------------------
    # FINAL RESULT
    # -------------------------------------
    Write-Host
    Write-Host "FINAL RESULT"
    Write-Host "----------------------------------------"
    $currentEmailAddress = $user.EmailAddress
     
    if ($currentEmailAddress) {
        Write-Host "   Mail Attribute is now:" $currentEmailAddress
    } else {
        Write-Host "   Mail Attribute is blank"
    }
 
    Write-Host ""
    Write-Host "   Proxy addresses are:"
    ForEach ($proxy in $user.ProxyAddresses) {
        Write-Host "      " $proxy
    }   
 
    Write-Host "Setting Values..."
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # Un-comment the below to update AD
    #
    #$result = Set-ADUser -Instance $user
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
    Write-Host
    Write-Host "**************************************************" 
    Write-Host
}