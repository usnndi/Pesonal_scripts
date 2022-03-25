# Extract Info Find and replace "(" with "<" and ")" with ">"
# Use =MID(LEFT(B2,FIND(">",B2)-1),FIND("<",B2)+1,LEN(B2))

Connect-ExchangeOnline
Get-Mailbox -resultsize unlimited | Select-Object name,@{n="Primary Size";e={(Get-MailboxStatistics $_.identity).totalItemsize}},
@{n="Primary Item Count";e={(Get-MailboxStatistics $_.identity).ItemCount}},
@{n="Archive Size";e={(Get-MailboxStatistics -archive $_.identity).TotalItemSize}},
@{n="Archive Item Count";e={(Get-MailboxStatistics -archive $_.identity).ItemCount}} | Export-Csv 'C:\Users\JohnLoveall\OneDrive - Convergence Networks, Inc\Desktop\1215221-Wieland-MBSizenArchive.csv' -NoType

#Change Liceses
Connect-AzureAD
Get-AzureADSubscribedSku | Select SkuPartNumber