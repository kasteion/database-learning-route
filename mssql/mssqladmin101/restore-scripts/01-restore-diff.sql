--Drop database BackupDatabase
--Create a test database
Use master
go
Create database BackupDatabase
go
use BackupDatabase
go
--Create table
Create table Products
(ProductID int IDENTITY (1,1) Primary Key,
ProductName varchar (100),
Brand varchar (100))
go
--Insert data into table
insert into Products values (&#39;motor&#39;,&#39;chevy&#39;)
insert into Products values (&#39;Hat&#39;,&#39;Nike&#39;)
insert into Products values (&#39;Shoe&#39;,&#39;Payless&#39;)
insert into Products values (&#39;Phone&#39;,&#39;Apple&#39;)
insert into Products values (&#39;Book&#39;,&#39;Green&#39;)
insert into Products values (&#39;Cup&#39;,&#39;Large&#39;)
--View data
select * from Products
--Take full database backup of six rows
BACKUP DATABASE [BackupDatabase]
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH NOINIT, --&lt;&lt; No override
NAME = N&#39;BackupDatabase-Full Database Backup&#39;,
STATS = 10
GO
--Insert data into table AFTER a full database backup, but before a transactional log
backup
Insert into Products values (&#39;Doll&#39;,&#39;Toy_R_us&#39;)
BACKUP LOG BackupDatabase
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH
NAME = N&#39;BackupDatabase-Transaction Log Backup&#39;,
STATS = 10
GO

Insert into Products values (&#39;House&#39;,&#39;Remax&#39;)
--another transaction log backup
BACKUP LOG BackupDatabase
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH
NAME = N&#39;BackupDatabase-Transaction Log Backup&#39;,
STATS = 10
GO

Insert into Products values (&#39;Car&#39;,&#39;Porche&#39;)
--Taking differential backups
BACKUP DATABASE [BackupDatabase]
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH DIFFERENTIAL ,
NOINIT,
NAME = N&#39;BackupDatabase-Differential Database Backup&#39;,
STATS = 10
GO
Insert into Products values (&#39;Chair&#39;,&#39;Walmart&#39;)
BACKUP LOG BackupDatabase
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH
NAME = N&#39;BackupDatabase-Transaction Log Backup&#39;,
STATS = 10
GO
Insert into Products values (&#39;Mouse&#39;,&#39;Apple&#39;)
BACKUP LOG BackupDatabase
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH
NAME = N&#39;BackupDatabase-Transaction Log Backup&#39;,
STATS = 10
GO
Insert into Products values (&#39;TV&#39;,&#39;Sony&#39;)
BACKUP DATABASE [BackupDatabase]
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH DIFFERENTIAL ,
NOINIT,
NAME = N&#39;BackupDatabase-Differential Database Backup&#39;,
STATS = 10
GO
Insert into Products values (&#39;Phone&#39;,&#39;Apple&#39;)

BACKUP LOG BackupDatabase
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH
NAME = N&#39;BackupDatabase-Transaction Log Backup&#39;,
STATS = 10
GO
--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
--Restore database using T SQL
--before restoring a database, if you can, take a very last transactional log backup to
save data:
--tail log
USE master
GO
BACKUP LOG BackupDatabase
TO DISK = N&#39;c:\fullbackups\BackupDatabase.bak&#39;
WITH NORECOVERY,
NAME = N&#39;BackupDatabase-Transaction Log Backup&#39;,
STATS = 10
GO
USE [master]
Go
RESTORE DATABASE [BackupDatabase]
FROM DISK = N&#39;C:\FullBackups\BackupDatabase.bak&#39;
WITH FILE = 1,
NORECOVERY,
NOUNLOAD,
STATS = 5
RESTORE DATABASE [BackupDatabase]
FROM DISK = N&#39;C:\FullBackups\BackupDatabase.bak&#39;
WITH FILE = 7,
NORECOVERY,
NOUNLOAD,
STATS = 5
RESTORE LOG [BackupDatabase]
FROM DISK = N&#39;C:\FullBackups\BackupDatabase.bak&#39;
WITH FILE = 8,
NORECOVERY,
NOUNLOAD,
STATS = 5
RESTORE LOG [BackupDatabase]
FROM DISK = N&#39;C:\FullBackups\BackupDatabase.bak&#39;
WITH FILE = 9,
RECOVERY,
NOUNLOAD,
STATS = 5

GO
RESTORE LOG [BackupDatabase]
FROM DISK = N&#39;C:\FullBackups\BackupDatabase.bak&#39;
WITH FILE = 10,
NORECOVERY,
NOUNLOAD,
STATS = 5
GO
RESTORE LOG [BackupDatabase]
FROM DISK = N&#39;C:\FullBackups\BackupDatabase.bak&#39;
WITH FILE = 11,
RECOVERY,
NOUNLOAD,
STATS = 5
GO