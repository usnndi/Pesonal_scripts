#get-aduser -Filter * -SearchBase "OU=ASKUsers,DC=justask,DC=local" -Properties objectguid |
get-aduser -Filter * -Properties objectguid |
	ForEach-Object{
		$sguid= [string]$_.objectguid
		$_|set-aduser -Replace @{extensionattribute15=$sguid}
	}