get-aduser -Identity Test.Everstream -Properties objectguid |
	ForEach-Object{
	    #$sguid = (Get-ADUser -Identity "Test.Everstream").objectGUID.ToString	
        $sguid= [string]$_.objectguid
	    $_|set-aduser -Add @{extensionattribute1=$sguid}
	}