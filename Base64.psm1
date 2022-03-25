#region Functions
#region Encode-ToBase64
Function Encode-ToBase64
{
    <#
    .SYNOPSIS
        Encode text to Base64.
 
    .DESCRIPTION
        The Encode-ToBase64 function encodes text to Base64 format.
 
    .PARAMETER Text
        The text to encode.
 
    .PARAMETER Encoding
        The encoding of the text
 
    .EXAMPLE
        $encodedText = Encode-ToBase64 -Text "This is a sample text."
 
        This command will encode the sample text to Base64 and store the result to the encodedText variable.
    #>

    Param
    (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The text to encode"
        )]
        [string]$Text,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The encoding of the text."
        )]
        [ValidateSet('ASCI', 'Unicode')]
        [string]$Encoding
    )

    # Convert text to bytes based on the encoding and then encode it to base64
    switch ($Encoding) 
    { 
        'Unicode'
            {
                $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
                $EncodedText =[Convert]::ToBase64String($Bytes)
                $EncodedText
            } 

        'ASCII'
            {
                $Bytes = [System.Text.Encoding]::ASCII.GetBytes($Text)
                $EncodedText =[Convert]::ToBase64String($Bytes)
                $EncodedText
            }
        default
            {
                $Bytes = [System.Text.Encoding]::Default.GetBytes($Text)
                $EncodedText =[Convert]::ToBase64String($Bytes)
                $EncodedText
            } 
    }
}
#endregion

#region Decode-FromBase64
Function Decode-FromBase64
{
    <#
    .SYNOPSIS
        Decode Base64 encoded text.
 
    .DESCRIPTION
        The Decode-FromBase64 function decodes Base64 encoded text.
 
    .PARAMETER EncodedText
        The text to decode.
 
    .PARAMETER Encoding
        The encoding of the text
 
    .EXAMPLE
        $decodedText = Decode-FromBase64 -EncodedText "VGhpcyBpcyBhIHNhbXBsZSB0ZXh0Lg=="
 
        This command will decode the sample encoded text from Base64 and store the result to the decodedText variable.
    #>

    Param
    (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The text to decode."
        )]
        [string]$EncodedText,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The encoding of the text."
        )]
        [ValidateSet('ASCI', 'Unicode')]
        [string]$Encoding
    )

    # Convert text to bytes based on the encoding and then encode it to base64
    switch ($Encoding) 
    { 
        'Unicode'
            {
                $DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($EncodedText))
                $DecodedText
            } 

        'ASCII'
            {
                $DecodedText = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($EncodedText))
                $DecodedText
            }
        default
            {
                $DecodedText = [System.Text.Encoding]::Default.GetString([System.Convert]::FromBase64String($EncodedText))
                $DecodedText
            }
    }
}
#endregion

#region Encode-GUIDToBase64
Function Encode-GUIDToBase64
{
    <#
    .SYNOPSIS
 
    Encode a GUID to Base64.
    .DESCRIPTION
 
    This function encodes a GUID object or it's string representation to base64.
    .PARAMETER GUIDString
 
    The string representation of the GUID
    .PARAMETER GUID
 
    The GUID as a GUID object
    .EXAMPLE
 
    Encode-GUIDToBase64 -GUIDString "8ff94579-2061-43c6-a350-ba5d08963cae"
 
    ObjectGUID EncodedGUID
    ---------- -----------
    8ff94579-2061-43c6-a350-ba5d08963cae eUX5j2EgxkOjULpdCD88rg==
 
    .EXAMPLE
 
    $guid = New-Object GUID (,"8734078f-ed7a-4fff-8cae-2d7bd9be52ac")
    Encode-GUIDToBase64 -GUID $guid
 
    ObjectGUID EncodedGUID
    ---------- -----------
    8734078f-ed7a-4fff-8cae-2d7bd9be52ac jwc0P3rt/08/ri172b5SrA==
 
    #>

    Param
    (
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "String")]
        [string]$GUIDString,
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "GUID" )]
        [GUID]$GUID
    )

    Begin{}

    Process
    {
        # The guid has been entered as a string
        if($GUIDString)
        {
            # Create a GUID object
            $myGuid = New-Object Guid (,$GUIDString)
        }

        # The guid has been entered as a GUID object
        if($GUID)
        {
            $myGuid = $GUID
        }

        # Get the bytes of the guid
        $bytequid = $myGuid.ToByteArray()

        # Convert the bytes to characters
        $tmp = ($bytequid | %{ [char]$_}) -join ""

        # encode to base64
        $encoded = Encode-ToBase64 $tmp

        # create a custom object
        $obj = New-Object psobject -Property @{
                                                "GUID" = $myGuid
                                                "EncodedGUID" = $encoded
                                            }
        
        # return the custom object
        $obj
    }

    End {}
}
#endregion

#endregion

#region Exports
Export-ModuleMember -Function Encode-ToBase64
Export-ModuleMember -Function Decode-FromBase64
Export-ModuleMember -Function Encode-GUIDToBase64
#endregion