get-aduser -Identity Test.Comlink2 -Properties objectguid |
	ForEach-Object{
	$sguid = (Get-ADUser -Identity "Test.Comlink2").objectGUID.ToString
     $sguid = [string]$_.objectguid
		$_|set-aduser -Add @{extensionattribute1=$sguid}
	}