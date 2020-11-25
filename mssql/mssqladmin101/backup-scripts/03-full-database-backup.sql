--Drop database BackupDatabase

--Create a test database

Use master
go

Create database BackupDatabase
go

--Find recovery mode

SELECT name, recovery_model_desc 
FROM sys.databases 
ORDER BY name

--ALTER DATABASE BackupDatabase SET RECOVERY FULL

use BackupDatabase 
go

--Create table

Create table Products
(ProductID int IDENTITY (1,1) Primary Key,
ProductName varchar (100),
Brand varchar (100))
go

--Insert data into table

insert into Products values ('motor','chevy')
insert into Products values ('Hat','Nike')
insert into Products values ('Shoe','Payless')
insert into Products values ('Phone','Apple')
insert into Products values ('Book','Green')
insert into Products values ('Cup','Large')

--View data

select * from Products

--Take full database backup of six rows

BACKUP DATABASE [BackupDatabase] 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH NOINIT,  --<< No override
NAME = N'BackupDatabase-Full Database Backup', 
STATS = 10
GO

--Verify that the database backup is valid (not that the data within is valid)

declare @backupSetId as int
select @backupSetId = position 
from msdb..backupset 
where database_name=N'BackupDatabase' 
and backup_set_id=(select max(backup_set_id) 
from msdb..backupset where database_name=N'BackupDatabase' )
if @backupSetId is null 
begin 
raiserror(N'Verify failed. Backup information for database ''BackupDatabase'' not found.', 16, 1) 
end
RESTORE VERIFYONLY 
FROM  
DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  FILE = @backupSetId
GO


--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--Insert data into table AFTER a full database backup, but before a transactional log backup

Insert into Products values ('Doll','Toy_R_us')

--View data

select * from Products

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)

BACKUP LOG BackupDatabase 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH 
NAME = N'BackupDatabase-Transaction Log  Backup', 
STATS = 10
GO

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--BackupType
--1 = Full
--2 = T Log
--5 = Differential


declare @backupSetId as int
select @backupSetId = position 
from msdb..backupset 
where database_name=N'BackupDatabase' and backup_set_id=(select max(backup_set_id) 
from msdb..backupset where database_name=N'BackupDatabase' )
if @backupSetId is null 
begin 
raiserror(N'Verify failed. Backup information for database ''BackupDatabase'' not found.', 16, 1) 
end
RESTORE VERIFYONLY 
FROM  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  FILE = @backupSetId
GO

 --Another insert

Insert into Products values ('House','Remax')

--another transaction log backup

BACKUP LOG BackupDatabase 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH 
NAME = N'BackupDatabase-Transaction Log  Backup', 
STATS = 10
GO

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'
























----Backup File Information
----It is possible to look at a backup file itself to get information about the backup. 
----The header of the backup stores data like when the backup was created, what type of backup it is, 
----the user who took the backup and all other sorts of information. The basic commands available are:

--	RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'
	
--	RESTORE LABELONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--	RESTORE FILELISTONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'


--Use msdb
--go

--SELECT logical_name,physical_name,file_number,backup_size,file_type, * 
--FROM dbo.backupfile
--ORDER BY 1  -- Contains one row for each data or log file that is backed up 

----SELECT * FROM dbo.backupmediafamily  -- Contains one row for each media family 
----SELECT * FROM dbo.backupmediaset -- Contains one row for each backup media set 
----SELECT * FROM dbo.backupset  -- Contains a row for each backup set 
----SELECT * FROM dbo.backupfilegroup -- Contains one row for each filegroup in a database at the time of backup 

BACKUP DATABASE [BackupDatabase] 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  DIFFERENTIAL , 
NOINIT,  
NAME = N'BackupDatabase-Differential Database Backup',   
STATS = 10
GO