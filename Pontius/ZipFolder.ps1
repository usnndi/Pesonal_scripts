$source = "C:\Users\cpontius\Documents\TestZip"

$destination = "C:\Users\cpontius\Documents\TestZip.zip"

 If(Test-path $destination) {Remove-item $destination}

Add-Type -assembly "system.io.compression.filesystem"

[io.compression.zipfile]::CreateFromDirectory($Source, $destination) 