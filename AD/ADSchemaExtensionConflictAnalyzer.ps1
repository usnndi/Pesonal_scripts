$count = 0
$operation = ""
$inputFile = ""
$currentSchema = ""
$errorCount = 0
$warningCount = 0
$multipleInputFiles = "false"

function global:DisplayScriptUsage {
	Write-Host "===================================================="
	Write-Host "`n EXTENSION CHECKER SCRIPT USAGE `n"
	Write-Host "===================================================="
	Write-Host "USAGE SUMMARY"
	Write-Host "`n -inputFile " -foregroundcolor darkCyan
	Write-Host "`n [REQUIRED FIELD] Provide the path to the input file containing the custom schema extensions here.`n"
	Write-Host "`n -outputFile " -foregroundcolor darkCyan
	Write-Host "`n [REQUIRED FIELD] Provide the path to the output LDF file containing the annotations and suggested corrections. `n"
	Write-Host "`n -currentSchema " -foregroundcolor darkCyan
	Write-Host "`n This is a required field if the operation is being run on a test DC."
	Write-Host " If the validate operation is being performed on a production DC, the current schema file need not be provided. The script will extract it.`n"
	Write-Host "EXAMPLES" -foregroundcolor darkCyan
	Write-Host " .\ExtensionChecker.ps1 -operation validate -inputfile sampleldf.ldf -outputfile results.ldf -currentschema myProductionSchema.ldf `n"
	exit
}

if ($args.length -lt 4){
	Write-Host "`nInsufficient number of parameters. Please check script usage" -foregroundcolor red
	DisplayScriptUsage
}

#Parsing arguments to grab Operation, Input Custom Extension File Name, Current Schema File Name
foreach ($i in $args){
	switch($count){
	0 {
		$comp = $i.ToLower().CompareTo("-inputfile")
		if ($comp -ne 0){
		Write-Host "Invalid switch where `'inputFile`' is expected" -foregroundcolor red
		exit
		}
	}

	1 {
		$inputFileList = $args[$count]
	}
	
	2 {
		$comp = $i.ToLower().CompareTo("-outputfile")
		if ($comp -ne 0){
			Write-Host "Invalid switch where `'outputfile`' is expected" -foregroundcolor red
			DisplayScriptUsage
			exit
		}
	}
	
	3 {
		$outputFile = $args[$count]
	}
	
	4 {
		$comp = $i.ToLower().CompareTo("-currentschema")
		if ($comp -ne 0){
			Write-Host "Invalid switch where currentSchema is expected"
			DisplayScriptUsage
			exit
		}
	}
	
	5 {
		$currentSchema = $args[$count]
	}
	}
$count++
}
	
# The function below will check current production schema file and/or the input custom extension file to make sure that the class / attribute being referenced (in systemMayContain,
# systemMustContain, mayContain, mustContain, subClassOf , systemAuxiliaryClass , auxiliaryClass , systemPossSuperiors , and possSuperiors) has already been created.
# If it has not been created but is still being referenced in one of the attributes above then that is an error and it needs to be flagged.
function global:ConfirmExistenceofReferencedAttributesOrClasses($attrClassList){
	$attrsClasses = $attrClassList.Split(",")
	
	foreach($item in $attrsClasses){
		if (!(select-string $currentSchema -pattern $item -quiet)){
			# The attribute/class under consideration was not found in current production schema file. We need to check the input file now. May be it is a new addition.
			$searchString = "CN=" + $item
			if(!(select-string $inputFile -pattern $searchString -quiet)){
				$searchString = "ldapdisplayname: " + $item
				if(!(select-string $inputFile -pattern $searchString -quiet)){
					# No declaration of the attribute/class under consideration was found in the inputFile too. Looks like an error. The attribute/class should have been created before referencing it.
					Write-Host "[Error] : The class or attribute under consideration " $item " is being referenced but has not been created so far. Please make sure it is created before using it." -foregroundcolor red
					$tempError = "###Error. The class or attribute under consideration - " + $item + " - is being referenced but has not been created so far. Please make sure it is created before using it."
					$errorCount++
					Add-Content -path $outputFile -value $tempError
				}
			}
		}
	}
}

# The function below will check current production schema file to look for a particular value of mapiid. Mapiid is expected to be unique.
function global:checkUniquenessOfMapiid([string]$mapiidValue){
if(select-string $currentSchema -pattern "mapiid" -quiet){
if(select-string $currentSchema -pattern $mapiidValue | foreach { $_.Line | select-string $mapiidValue -quiet} ){
Write-Host "[Error] : The mapiid value specified seems to be already in use. Please make sure the mapiid is unique." -foregroundcolor red
Add-Content -path $outputFile -value "###Error : The mapiid value specified seems to be already in use. Please make sure the mapiid is unique."
$errorCount++
}

}
}

# The function below will go through current production schema file to make sure the attribute/class that is being added is not already present in the current production schema
function global:checkExistence([string]$cnValue){
$ConsolidatedFileContent = gc $currentSchema
foreach ( $line in $ConsolidatedFileContent){
$SchemaValues = @($line.Split(":"))
if ($SchemaValues[1].length -gt 0){
$SchemaValues[1] = $SchemaValues[1].TrimStart(" ")
}
if (!$SchemaValues[0].CompareTo("lDAPDisplayName") -AND $SchemaValues[1].Contains($cnValue)){
Write-Host "[Error] : Attempt being made to add an attribute/class which already exists in the schema." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. Attempt being made to add an attribute/class which already exists in the schema."
$errorCount++
}
}
}

# The function below will go through current production schema file to look for the attribute $attrName which has been set as rdnAttid for another attribute
# The syntax of $attrName should be UNICODE 2.5.5.9
function global:checkSyntaxOfRdnattidAttribute($attrName){
$ConsolidatedFileContent = gc $currentSchema
$encounteredDn = 0
# The variable $encounteredDn will track whether or not we have come across the block that describes the attribute $attrName.
# Every "dn: " statement in the current production schema file will be checked till $attrName is encountered. On encountering it $encounteredDn will be set to 1.
# Once $attrName has been found its attributeSyntax attribute needs to be verified to make sure its value is 2.5.5.9
foreach ( $line in $ConsolidatedFileContent){
if( $encounteredDn -eq 0){
$SchemaValues = @($line.Split(":"))
if ($SchemaValues[1].length -gt 0){
$SchemaValues[1] = $SchemaValues[1].TrimStart(" ")
}
if (!$SchemaValues[0].CompareTo("dn") -AND $SchemaValues[1].Contains($attrName)){
$encounteredDn = 1
continue
}
}
else{
$SchemaValues = @($line.Split(":"))
if ($SchemaValues[1].length -gt 0){
$SchemaValues[1] = $SchemaValues[1].TrimStart(" ")
}
if (!$SchemaValues[0].CompareTo("attributeSyntax")){
if($SchemaValues[1].CompareTo("2.5.5.9")){
#This means attributeSyntax of the attribute which is the rdnAttid for another attribute is not INTEGER. This is not expected.
Write-Host "[Error] : AttributeSyntax of rdnattid attribute should be INTEGER 2.5.5.9. Please correct." -foregroundcolor red
Add-Content -path $outputFile -value "### AttributeSyntax of rdnattid attribute should be INTEGER 2.5.5.9. Please correct."
$errorCount++
}
break
}
}
}
}

function global:ValidateExtensions{

if ( $inputFile.length -eq 0){
Write-Host "No input extension file has been specified. Please check script usage to make sure you are providing the input custom extension file name."
exit
}

if(!(test-path $inputFile)){
Write-Host "Input file provided " $inputFile " does not exist. Please check the path and try again." -foregroundcolor red
exit
}

if ( $currentSchema.length -eq 0){
Write-Host "No current schema file has been specified. Now attempting to grab the schema of the host machine"
$currentSchema = "currentSchema.ldf"
$argString = "'-f currentSchema.ldf -d #SchemaNamingContext -c #DefaultNamingContext DC=X'"
start ldifde.exe -Argu '-f currentSchema.ldf -d #SchemaNamingContext -c #DefaultNamingContext DC=X' -wait

}
else{
if(!(test-path $currentSchema)){
Write-Host "Current production schema file provided " $currentSchema " does not exist. Please check the path and try again." -foregroundcolor red
exit
}
}

Write-Host "`nValidating input file : " $inputFile

$NewFileContent = gc $inputFile

$attributeSyntaxList = @{
"2.5.5.1" = " ( DISTNAME )";
"2.5.5.2" = " ( OBJECT_ID )";
"2.5.5.3" = "( CASE_STRING )";
"2.5.5.4" = "( NOCASE_STRING )";
"2.5.5.5" = "( PRINT_CASE_STRING )";
"2.5.5.6" = "( NUMERIC_STRING )";
"2.5.5.7" = "( DISTNAME_BINARY )";
"2.5.5.8" = "( BOOLEAN )";
"2.5.5.9" = "( INTEGER )";
"2.5.5.10" = "( OCTET_STRING )";
"2.5.5.11" = "( TIME )";
"2.5.5.12" = "( UNICODE )";
"2.5.5.13" = "( ADDRESS )";
"2.5.5.14" = "( DISTNAME_STRING )";
"2.5.5.15" = "( NT_SECURITY_DESCRIPTOR )";
"2.5.5.16" = "( I8 )";
"2.5.5.17" = "( SID )"
}
$systemFlagsList = @{
0x1 = "FLAG_ATTR_NOT_REPLICATED";
0x2 = "FLAG_ATTR_REQ_PARTIAL_SET_MEMBER";
0x4 = "FLAG_ATTR_IS_CONSTRUCTED";
0x8 = "FLAG_ATTR_IS_OPERATIONAL";
0x10 = "FLAG_SCHEMA_BASE_OBJECT";
0x20 = "FLAG_ATTR_IS_RDN";
0x8000000 = "FLAG_DOMAIN_DISALLOW_RENAME"
}
$searchFlagsList = @{
1 = "fATTINDEX";
2 = "fPDNTATTINDEX";
4 = "fANR";
8 = "fPRESERVEONDELETE";
16 = "fCOPY";
32 = "fTUPLEINDEX";
64 = "fSUBTREEATTINDEX";
128 = "fCONFIDENTIAL";
256 = "fNEVERVALUEAUDIT";
512 = "fRODCFilteredAttribute"
}
$oMSyntaxList = @{
"0" = "( NO_MORE_SYNTAXES )";
"1" = "( BOOLEAN )";
"2" = "( INTEGER )";
"3" = "( BIT_STRING )";
"4" = "( OCTET_STRING )";
"5" = "( NULL )";
"6" = "( OBJECT_IDENTIFIER_STRING )";
"7" = "( OBJECT_DESCRIPTOR_STRING )";
"8" = "( ENCODING_STRING )";
"10" = "( ENUMERATION )";
"18" = "( NUMERIC_STRING )";
"19" = "( PRINTABLE_STRING )";
"20" = "( TELETEX_STRING )";
"21" = "( VIDEOTEX_STRING )";
"22" = "( IA5_STRING )";
"23" = "( UTC_TIME_STRING )";
"24" = "( GENERALISED_TIME_STRING )";
"25" = "( GRAPHIC_STRING )";
"26" = "( VISIBLE_STRING )";
"27" = "( GENERAL_STRING )";
"64" = "( UNICODE_STRING )";
"65" = "( I8 )";
"66" = "( OBJECT_SECURITY_DESCRIPTOR )";
"127" = "( OBJECT )"
}
$oMObjectClassList = @{
"KoZIhvcUAQEBBg==" = "1.2.840.113556.1.1.1.6 (REPLICA-LINK)";
"KoZIhvcUAQEBCw==" = "1.2.840.113556.1.1.1.11 (DN-BINARY)";
"KoZIhvcUAQEBDA==" = "1.2.840.113556.1.1.1.12 (DN-STRING)";
"KwwCh3McAIVK" = "1.35.44.2.1011.60.0.746 (DS-DN)";
"KwwCh3McAIU+" = "1.35.44.2.1011.60.0.734 (ACCESS-POINT)";
"KwwCh3McAIVc" = "1.35.44.2.1011.60.0.764 (PRESENTATION-ADDRESS)";
"VgYBAgULHQ==" = "2.6.6.1.2.5.43.61 (OR-NAME)"
}
$attributeSyntaxToOmSyntaxList = @{
"2.5.5.1" = "127";
"2.5.5.2" = "6";
"2.5.5.3" = "27";
"2.5.5.4" = "20";
"2.5.5.5" = "19,22";
"2.5.5.6" = "18";
"2.5.5.7" = "127";
"2.5.5.8" = "1";
"2.5.5.9" = "2,10";
"2.5.5.10" = "4";
"2.5.5.11" = "23,24";
"2.5.5.12" = "64";
"2.5.5.13" = "127";
"2.5.5.14" = "127";
"2.5.5.15" = "66";
"2.5.5.16" = "65";
"2.5.5.17" = "4"
}

$linkedAttrsDisplayNameList = @{}
$linkedAttrsOIDList = @{}

$schemaUpdateNowFlag = "FALSE"
$startedAddingClassesFlag = "FALSE"

$ldapDisplayNameVal = "NULL"

#Now start scanning the input ldf file
$linecount = 0

# If multiple input files are present then output ldf file should be created only once. Else the earlier data will be erased.
# If a single input file is present (or if there are multiple input files but this is the first input file that is being validated) $multipleInputFiles will contain "false".
# Hence it will go inside the if block below and create a new output file.
if(!$multipleInputFiles.CompareTo("false")){
# Either this is the first of multiple input files or this is a single input file case. Either way we need to create an output file once. Let's do that.
Write-Host "`n Creating a new output file containing annotations and suggested corrections for input file : " $inputFile
New-Item -ItemType file $outputFile -force
}

Add-Content -path $outputFile -value "########################################"
Add-Content -path $outputFile -value "#Scanned LDF file with corrections"
$tempStr = "#Input file : " + $inputFile
Add-Content -path $outputFile -value $tempStr

Write-Host "`n"
foreach($line in $NewFileContent){
$linecount++
if ($line.StartsWith("#")){
#We want to ignore comments
continue
}
else{
#to get an array of items, Values[0]..Values[x-1] where [x] is the number of items created
Add-Content -path $outputFile -value $line
$Values = @($line.Split(":"))

if ( $values[1].length -gt 0){
$values[1] = $values[1].TrimStart(" ")
}
else{
continue
}

Write-Host "Line #" $linecount
write-host "Attribute :"$values[0]
write-host "Value :"$values[1]

$tempStr = ""
$cnValue = ""
$values[0] = $values[0].ToLower()
switch -wildcard ($values[0]){
"attributesyntax"
{
$attributeSyntaxValue = $values[1]
$values[1] = $values[1].TrimStart(" ")
if( !$attributeSyntaxList.ContainsKey($values[1])){
Write-Host "[Error] : The value provided for attribute syntax is invalid. Please correct the value." -foregroundcolor red
$tempError = "###Error. The value provided for attribute syntax is invalid. Please correct the value."
Add-Content -path $outputFile -value $tempError
$attributeSyntaxValue = ""
$errorCount++
continue
}
Write-Host "attributeSyntax is :" $attributeSyntaxList[$values[1]]
$tempStr = "# attributeSyntax is :" + $attributeSyntaxList[$values[1]]
Add-Content -path $outputFile -value $tempStr
}

"systemflags"
{
$values[1] = $values[1].TrimStart(" ")
$flags = "";
for ($i = 1; $i -le 0x8000000; $i *= 2){
if ($values[1] -band $i){
if ($flags.length -gt 0){
$flags = $flags + " | " + $systemFlagsList[$i]
}
else{
if (!$systemFlagsList.ContainsKey($i)){
Write-Host "[Error] : The systemFlags value is invalid. Please correct it."
Add-Content -path $outputFile -value "###Error. The systemFlags value is invalid. Please correct it."
$errorCount++
continue
}
$flags = $systemFlagsList[$i]
}

if ( $i -eq 0x10){
# systemFlags contains 0x10 which means base schema object. This needs to be flagged.
Write-Host "[Warning] : This attribute/class has been marked as BASE_SCHEMA_OBJECT. This would need approval from active directory schema team." -Foregroundcolor red
Add-Content -path $outputFile -value "###Warning. This attribute/class has been marked as BASE_SCHEMA_OBJECT. This would need approval from active directory schema team."
}
}
}
$tempStr = "# systemFlags is:" + $flags
Write-Host "systemFlags is:" $flags
Add-Content -path $outputFile -value $tempStr
}

"searchflags"
{
$values[1] = $values[1].TrimStart(" ")
$flags = "";
for ($i = 1; $i -le 512; $i *= 2){
if ($values[1] -band $i){
if ($flags.length -gt 0){
$flags = $flags + " | " + $searchFlagsList[$i]

} else{
$flags = $searchFlagsList[$i]
}

if ($i -eq 8){
# fPreserveOnDelete is set. Make sure this is really required
Add-Content -path $outputFile -value "###Warning. This attribute has been marked as preserveOnDelete. Please confirm the need to do so."
Write-Host "[Warning] : This attribute has been marked as fpreserveOnDelete. Please confirm the need to do so." -foregroundcolor red
$warningCount++
}

if($i -eq 128){
#fConfidential is set. Make sure this is really required
Add-Content -path $outputFile -value "###Warning. This attribute has been marked as fConfidential. Please confirm the need to do so."
Write-Host "[Warning] : This attribute has been marked as fConfidential. Please confirm the need to do so." -foregroundcolor red
$warningCount++
}
}
}
Write-Host "searchFlags is :" $flags
$tempStr = "# searchFlags :" + $flags
Add-Content -path $outputFile -value $tempStr
}

"omsyntax"
{
$values[1] = $values[1].TrimStart(" ")
write-Host "oMSyntax is :" $oMSyntaxList[$values[1]]
if(!$oMSyntaxList.ContainsKey($values[1])){
Write-Host "[Error] : The value provided for oMSyntax is invalid. Please correct the value." -foregroundcolor red
Add-Content -path $outputFile -value "###Error. The value provided for oMSyntax is invalid. Please correct the value."
$errorCount++
continue
}
$tempStr = "#oMSyntax :" + $oMSyntaxList[$values[1]]
Add-Content -path $outputFile -value $tempStr
$compareResult = $values[1].CompareTo($attributeSyntaxToOmSyntaxList[$attributeSyntaxValue])
if ( $compareResult -ne 0)
{
$omValues = @($attributeSyntaxToOmSyntaxList[$attributeSyntaxValue].Split(","))
$compareResult = $values[1].CompareTo($omValues[0])
if( $compareResult -ne 0){
$compareResult = $values[1].CompareTo($omValues[1])
if( $compareResult -ne 0){
Add-Content -path $outputFile -value "### Error.oMSyntax does not seem to match the attributeSyntax value specified earlier for this attribute"
Write-Host "###[Error] : oMSyntax does not seem to match the attributeSyntax value specified earlier for this attribute" -foregroundcolor red
}
}
}
$attributeSyntaxValue = ""
}

"omobjectclass"
{
$values[1] = $values[1].TrimStart(" ")
if (!$oMObjectClassList.ContainsKey($values[1])){
Write-Host "[Error] : oMObjectClass specified is invalid. Please correct the value and try again." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. oMObjectClass specified is invalid. Please correct the value and try again."
$errorCount++
continue
}
Write-Host "ObjectClass is:" $oMObjectClassList[$values[1]]
$tempStr = "#ObjectClass is:" + $oMObjectClassList[$values[1]]
Add-Content -path $outputFile -value $tempStr
$objectClass = $values[1];
}

"objectclass"
{
if($values[1].CompareTo("classSchema") -eq 0){
if($schemaUpdateNowFlag.CompareTo("TRUE") -ne 0 -and $startedAddingClassesFlag.CompareTo("TRUE") -eq 0){
Write-Host "[Error] : schemaUpdateNow needs to be inserted before adding new classes." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. schemaUpdateNow needs to be inserted before adding new classes."
$startedAddingClassesFlag = "TRUE"
$errorCount++
}
}
}

"admindescription"
{
if ( $values[1].length -le 1){
Add-Content -path $outputFile -value "### Error.Adequate description has not been specified. Please correct this."
Write-Host "[Error] : Adequate description has not been specified. Please correct this." -foregroundcolor red
$errorCount++
}
}

"systemonly"
{
$systemOnlyCheck = $values[1].CompareTo("TRUE")
if ( $systemOnlyCheck -eq 0){
#Object has been flagged as systemOnly. Needs to be checked further.
Write-Host "[Error] : This object has been marked as systemOnly. This needs approval from the Active Directory schema team." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. This object has been marked as systemOnly. This needs approval from the Active Directory schema team."
$errorCount++
}
}

"attributeid"
{
$OIDCheck = $values[1].StartsWith("1.2.840.113556.1")
if (!$OIDCheck){
#OID might be wrong
Write-Host "[Error] : The OID value is invalid. It should start with 1.2.840.113556.1.Please correct the OID and then re-try." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. The OID value is invalid. It should start with 1.2.840.113556.1.Please correct the OID and then re-try."
$errorCount++
}
}

"governsid"
{
$OIDCheck = $values[1].StartsWith("1.2.840.113556.1")
if (!$OIDCheck){
#OID might be wrong
Write-Host "[Error] : The OID value is invalid. It should start with 1.2.840.113556.1.Please correct the OID and then re-try." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. The OID value is invalid. It should start with 1.2.840.113556.1.Please correct the OID and then re-try."
$errorCount++
}
}
"changetype"
{
$changetypeValue = $values[1]
#When you come across a "changeType" that means an attempt is being made to add /modify an existing object
$schemaUpdateNowFlag = "FALSE"
}

"cn"
{
$cnValue = $values[1]
if ($changetypeValue.CompareTo("ntdsSchemaAdd") -eq 0){
# add operation is being performed for this attribute/class. Make sure that the object doesn't already exist in the schema.
checkExistence($cnValue)
}
$cnValue = ""
$changetypeValue = ""
}
"mapiid"
{
checkUniquenessOfMapiid($values[1])
}

# systemMayContain, systemMustContain,systemAuxiliaryClass, systemPossSuperiors
# mayContain, mustContain
# subClassOf ,
# auxiliaryClass
# possSuperiors
# ConfirmExistenceofReferencedAttributesOrClasses($attrClassList)

"systemmaycontain"
{
if($changeTypeValue.CompareTo("ntdsSchemaModify") -eq 0){
Write-Host "[Error] : A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted" -foregroundcolor red
Add-Content -path $outputFile -value "###Error. A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted."
$errorCount++
}
else{
Write-Host $changeTypeValue " operation so system attribute addition is permitted"
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}

}

"systemmustcontain"
{
if($changeTypeValue.CompareTo("ntdsSchemaModify") -eq 0){
Write-Host "[Error] : A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted" -foregroundcolor red
Add-Content -path $outputFile -value "###Error. A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted."
$errorCount++
}
else{
Write-Host $changeTypeValue " operation so system attribute addition is permitted"
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}

}

"systemAuxiliaryClass"
{
if($changeTypeValue.CompareTo("ntdsSchemaModify") -eq 0){
Write-Host "[Error] : A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted" -foregroundcolor red
Add-Content -path $outputFile -value "###Error. A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted."
$errorCount++
}
else{
Write-Host $changeTypeValue " operation so system attribute addition is permitted"
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}
}

"systemPossSuperiors"
{
if($changeTypeValue.CompareTo("ntdsSchemaModify") -eq 0){
Write-Host "[Error] : A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted" -foregroundcolor red
Add-Content -path $outputFile -value "###Error. A systemOnly attribute is being added to an existing object. This operation is not allowed. Addition of systemOnly attributes while creating new objects is permitted."
$errorCount++
}
else{
Write-Host $changeTypeValue " operation so system attribute addition is permitted"
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}

}

"m*contain"
{
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}

"subclassof"
{
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}

"*auxiliaryclass"
{
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}

"posssuperiors"
{
ConfirmExistenceofReferencedAttributesOrClasses($values[1])
}

"ismemberofpartialattributeset"
{
$values[1] = $values[1].ToLower()
if($values[1].CompareTo("true") -eq 0){
Write-Host "[Warning] : Attribute has been marked as a member of the partial attribute set. Please confirm the requirement for the same." -foregroundcolor red
Add-Content -path $outputFile -value "### Attribute has been marked as a member of the partial attribute set. Please confirm the requirement for the same."
$warningCount++
}
}

"schemaupgradeinprogress"
{
$values[1] = $values[1].ToLower()
if($values[1].CompareTo("true") -eq 0){
Write-Host "[Error] : Invalid element. Please consider removing it." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. Invalid element. Please consider removing it."
$errorCount++
}
}

"schemaupdatenow"
{
if($values[1].CompareTo("1") -eq 0){
$schemaUpdateNowFlag = "TRUE";
}
}

"oid"
{
$oid = $values[1];
}

"ldapdisplayname"
{
$ldapDisplayNameVal = $values[1];
if ($changetypeValue.CompareTo("ntdsSchemaAdd") -eq 0){
# add operation is being performed for this attribute/class. Make sure that the object doesn't already exist in the schema.
checkExistence($ldapDisplayNameVal)
}
$ldapDisplayNameVal = ""
$changetypeValue = ""
}

"linkid"
{
if ($values[1] -eq "1.2.840.113556.1.2.50"){
$linkedAttrsDisplayNameList.Add($ldapDisplayNameVal, 0);
$linkedAttrsOIDList.Add($oid, 0);
}
else{
if(!$linkedAttrsDisplayNameList.ContainsKey($values[1])){
if(!$linkedAttrsOIDList.ContainsKey($values[1])){
Write-Host "[Error] : An attempt is being made to access a forward link that doesn't seem to exist. If this is a hardcoded link id that is not valid. Please follow the guidelines for obtaining a link id." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. An attempt is being made to access a forward link that doesn't seem to exist. If this is a hardcoded link id that is not valid. Please follow the guidelines for obtaining a link id."
$errorCount++
}
else{
$linkedAttrsOIDList[$values[1]] = $linkedAttrsOIDList[$values[1]] + 1;
}
}
else{
$linkedAttrsDisplayNameList[$values[1]] = $linkedAttrsDisplayNameList[$values[1]] + 1;
Write-Host "A forward link does exist for this back link. Usage is valid."
Add-Content -path $outputFile -value "###A forward link does exist for this back link. Usage is valid."
}
}
}

"objectclasscategory"
{
$values[1] = $values[1].TrimStart(" ")
switch ($values[1]){
"structural"
{
Add-Content -path $outputFile -value "###ObjectClassCategory : Structural"
}

"auxiliary"
{
Add-Content -path $outputFile -value "###ObjectClassCategory : Auxiliary"
}

"abstract"
{
Add-Content -path $outputFile -value "###ObjectClassCategory : Abstract"
}

"88"
{
Add-Content -path $outputFile -value "###ObjectClassCategory : 88"
}

default
{
Write-Host "[Error] : The value provided for objectClassCategory " $values[1] " is not valid. Please correct it and try again. Accepted values are Structural, Auxiliary, Abstract, 88." -foregroundcolor red
Add-Content -path $outputFile -value "### Error. The value provided for objectClassCategory " $values[1] " is not valid. Please correct it and try again. Accepted values are Structural, Auxiliary, Abstract, 88."
$errorCount++
}
}
}

"rdnattid"
{
checkSyntaxOfRdnattidAttribute($values[1])
}

"changetype"
{
$values[1]=$values[1].ToLower()
switch($values[1])
{
"add"
{
Write-Host "Allowed changetype"
}

"ntdsschemaadd"
{
Write-Host "Allowed changetype"
}

"modify"
{
Write-Host "Allowed changetype"
}

"ntdsschemamodify"
{
Write-Host "Allowed changetype"
}

"delete"
{
Write-Host "Allowed changetype"
}

"ntdsschemadelete"
{
Write-Host "Allowed changetype"
}

"ntdsschemamodrdn"
{
Write-Host "Allowed changetype"
}

default
{
Write-Host "[Error] : ChangeType " $values[1] " is invalid. Allowed changeType values are - add, ntdsschemaadd, modify, ntdsschemamodify, delete, ntdsschemadelete, ntdsschemamodrdn."
Add-Content -path $outputFile -value "### Error. ChangeType value is invalid. Allowed changeType values are - add, ntdsschemaadd, modify, ntdsschemamodify, delete, ntdsschemadelete, ntdsschemamodrdn."
$errorCount++
}
}
}

}
write-host "*****************************************************************" -foregroundcolor darkcyan
}

}

Write-Host "`n Summary" -foregroundcolor DarkGreen
Write-Host "Errors : " $errorCount -foregroundcolor DarkGreen
Write-Host "Warnings : " $warningCount -foregroundcolor DarkGreen

#Now that the whole file has been checked go through the $linkedAttrsOIDList and $linkedAttrsDisplayNameList to make sure the reference counts are &gt; 0
#A count of zero means that a forward link was created but a back link was never created for it
}

function global:ExtensionChecker($args){
	Write-Host "Validating Extensions..."
	foreach ($iFile in $inputFileList){
		$inputFile = $iFile
		ValidateExtensions
		$multipleInputFiles = "true"
	}
}

ExtensionChecker($args)