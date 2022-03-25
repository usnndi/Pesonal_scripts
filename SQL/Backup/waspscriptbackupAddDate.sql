declare @backupfile nvarchar(2000)
set @backupfile = N'C:\USALBCINCI\WaspDBCinci' + Convert(nvarchar(30), getdate(), 110) + N'.BAK'
BACKUP DATABASE [WaspTime] TO  DISK = @backupfile
WITH NOINIT , 
NOUNLOAD , 
DIFFERENTIAL ,
NAME = N'WaspTime-Full Database Backup',
SKIP,
STATS = 10, 
NOFORMAT
GO