--Restore database using T SQL

USE [master]
RESTORE DATABASE [BackupDatabase] 
FROM  DISK = N'C:\FullBackups\BackupDatabase.bak' 
WITH  FILE = 1,  
NORECOVERY,  
NOUNLOAD,  
STATS = 5

RESTORE DATABASE [BackupDatabase] 
FROM  DISK = N'C:\FullBackups\BackupDatabase.bak' 
WITH  FILE = 7,  
NORECOVERY,  
NOUNLOAD,  
STATS = 5

RESTORE LOG [BackupDatabase] 
FROM  DISK = N'C:\FullBackups\BackupDatabase.bak' 
WITH  FILE = 8,  
NOUNLOAD,  
STATS = 5

GO
