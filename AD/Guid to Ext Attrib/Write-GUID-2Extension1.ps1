$guid = (get-Aduser test.comlink).ObjectGuid
get-aduser -Identity test.comlink -Properties objectguid |
	ForEach-Object{
        $guid = (get-Aduser test.comlink).ObjectGuid
        $immutableID = [System.Convert]::ToBase64String($guid.tobytearray())	
    	$_|set-aduser -Add @{extensionattribute1=$immutableID}
	}