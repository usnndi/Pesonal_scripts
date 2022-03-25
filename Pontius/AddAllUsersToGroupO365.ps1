$group = get-msolgroup | where {$_.Displayname -eq “SharePoint Document Read Only”}
$users = get-msoluser | select userprincipalname,objectid | where {$_.userprincipalname -like “*medallionmgmt.com*”}
$users | foreach {add-msolgroupmember -groupobjectid $group.objectid -groupmembertype “user” -GroupMemberObjectId $_.objectid}