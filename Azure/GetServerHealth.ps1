## This is the location the script will save the output file

$OutputFile="C:\admin\ServerStatus.htm"

 

## Replace these values with valid from and to email addresses

$smtpFrom = "sender@domain1.com"

$smtpTo = "recipient@domain2.com"

 

$CPU = Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average

$Mem = gwmi -Class win32_operatingsystem |

Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}

$Disk = Get-WmiObject -Class win32_Volume -Filter "DriveLetter = 'C:'" |

Select-object @{Name = "CFree"; Expression = {“{0:N2}” -f (($_.FreeSpace / $_.Capacity)*100) } }

 

$Outputreport = "<HTML><TITLE> Current Server Health </TITLE>

<H2> Server Health </H2></font>

<Table border=1 cellpadding=5 cellspacing=0>

<TR>

<TD><B>Average CPU</B></TD>

<TD><B>Memory Used</B></TD>

<TD><B>C Drive</B></TD></TR>

<TR>

<TD align=center>$($CPU.Average)%</TD>

<TD align=center>$($MEM.MemoryUsage)%</TD>

<TD align=center>$($Disk."CFree")% Free</TD></TR>

</Table></BODY></HTML>"

 

$Outputreport | out-file $OutputFile

 

## Send the email

$smtpServer = "localhost"

$messageSubject = "Current server health"

$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto

$message.Subject = $messageSubject

$message.IsBodyHTML = $true

$message.Body = "<head><pre>$style</pre></head>"

$message.Body += Get-Content $OutputFile

$smtp = New-Object Net.Mail.SmtpClient($smtpServer)

$smtp.Send($message)