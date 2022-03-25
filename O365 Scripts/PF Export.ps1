#Needs to run an account with PublishingAuthor rights to the PFs
#
# Kev Maitland 08/09/15

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://mahp-exch01.mahp.local/PowerShell/ -Authentication Kerberos 
Import-PSSession $Session -AllowClobber

$EWSServicePath = '\\mahp-exch01\C$\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll'
Import-Module $EWSServicePath

#If necessary, grant Owner permissions to each folder the Public Folder hierarchy to ensure we export everything
#Get-PublicFolder -Identity "\" -Recurse | Add-PublicFolderClientPermission -AccessRights Owner -User "mahp\mahpadadmin"


#Set some variables
$ExchVer = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2013_SP1
$ewsUrl = "https://192.168.1.5/EWS/Exchange.asmx"
$upnExtension = "mahp.org"
$smtpServer = "mahp-exch01.mahp.local"
$pFRootPath = "\"
$outputPathRoot = "C:\Temp"

#Prepare some functions From Glen Scales http://gsexdev.blogspot.co.uk/2013/08/public-folder-ews-how-to-rollup-part-1.html
function FolderIdFromPath{  
    param ($FolderPath = "$( throw 'Folder Path is a mandatory Parameter' )")  
    process{  
        ## Find and Bind to Folder based on Path    
        #Define the path to search should be seperated with \    
        #Bind to the MSGFolder Root    
        $folderId = new-object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::PublicFoldersRoot)     
        $tfTargetFolder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service,$folderId)    
        #Split the Search path into an array    
        $fldArray = $FolderPath.Split("\")  
         #Loop through the Split Array and do a Search for each level of folder  
        for ($lint = 1; $lint -lt $fldArray.Length; $lint++) {  
            #Perform search based on the displayname of each folder level  
            $fvFolderView = new-object Microsoft.Exchange.WebServices.Data.FolderView(1)  
            $SfSearchFilter = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName,$fldArray[$lint])  
            $findFolderResults = $service.FindFolders($tfTargetFolder.Id,$SfSearchFilter,$fvFolderView)  
            if ($findFolderResults.TotalCount -gt 0){  
                foreach($folder in $findFolderResults.Folders){  
                    $tfTargetFolder = $folder                 
                }  
            }  
            else{  
                "Error Folder Not Found"   
                $tfTargetFolder = $null   
                break   
            }      
        }   
        if($tfTargetFolder -ne $null){ 
            return $tfTargetFolder.Id.UniqueId.ToString() 
        } 
    } 
} 
function getPublicFolderViaEws([string]$publicFolderPath){
    $folderId = new-object Microsoft.Exchange.WebServices.Data.FolderId(FolderIdFromPath -FolderPath $publicFolderPath)
    [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service,$folderId)    
    }

#Get set up using the current user's security context
$windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$sidbind = "LDAP://<SID=" + $windowsIdentity.user.Value.ToString() + ">"
$aceuser = [ADSI]$sidbind
$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($exchver)
$service.Url = $ewsUrl
$service.AutodiscoverUrl($aceuser.mail.ToString())

$propertySet = new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)  #Get all the default properties of the items in the Public Folders
$propertySet.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::MimeContent)  #Add the MimeContent property too, so that we can send it directy to the filestream later



foreach ($folderPS in Get-PublicFolder -Recurse){
    New-Item -Path "$outputPathRoot$($folderPS.ParentPath)\$($folderPS.Name)" -ItemType Directory #Make a filesystem folder to match the Public Folder hierarchy
    $folderEws = getPublicFolderViaEws -publicFolderPath "$($folderPS.ParentPath)\$($folderPS.Name)".Replace("\\","\") #Bodge the odd occasion where we end up with two backslashes in a folder name
    $itemView =  New-Object Microsoft.Exchange.WebServices.Data.ItemView(10)  
    $foundItems = $null  
    do{  
        $foundItems = $service.FindItems($folderEws.Id,$itemView) #Get the first batch of objects in the current Public Folder
        [Void]$service.LoadPropertiesForItems($foundItems,$propertySet) #Load the properties we specified earlier
        $i = $null
        foreach($email in $foundItems.Items){
            while(Test-Path "$outputPathRoot$($folderPS.ParentPath)\$($folderPS.Name)\$($email.Subject.Replace(":",'').Replace("/",'').Replace("\",'').Replace("*",'').Replace("?",'').Replace("<",'').Replace(">",'').Replace("|",''))$i"){ #Remove all illegal filesystem characters from the subject of the e-mail. If the result already exists on the filesystem, add an incremented number until it is unique (so that we don't accidentally overwrite e-mail threads)
                $i++
                }
            [System.IO.File]::WriteAllBytes("$outputPathRoot$($folderPS.ParentPath)\$($folderPS.Name)\$($email.Subject.Replace(":",'').Replace("/",'').Replace("\",'').Replace("*",'').Replace("?",'').Replace("<",'').Replace(">",'').Replace("|",''))$i.eml", $email.MimeContent.Content) #Stream the MimeContent to a file on the filesystem
            }
        $itemView.Offset += $foundItems.Items.Count  #Get ready to process the next batch of e-mails in the Public Folder
        }
    while($foundItems.MoreAvailable -eq $true) 
    }