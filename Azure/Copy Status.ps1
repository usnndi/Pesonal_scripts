while(($blobCopy | Get-AzureStorageBlobCopyState).Status -eq "Pending")
{
    Start-Sleep -s 30
    $blobCopy | Get-AzureStorageBlobCopyState
}
