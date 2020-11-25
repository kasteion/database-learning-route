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

insert into Products values ('Bike','Genesis')
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
WITH NOINIT,  
NAME = N'BackupDatabase-Full Database Backup', 
COMPRESSION,  
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


Use msdb
go

SELECT logical_name,physical_name,file_number,backup_size,file_type, * 
FROM dbo.backupfile
ORDER BY 1  -- Contains one row for each data or log file that is backed up 

--SELECT * FROM dbo.backupmediafamily  -- Contains one row for each media family 
--SELECT * FROM dbo.backupmediaset -- Contains one row for each backup media set 
--SELECT * FROM dbo.backupset  -- Contains a row for each backup set 
--SELECT * FROM dbo.backupfilegroup -- Contains one row for each filegroup in a database at the time of backup 


--Extented backup script wtih options

BACKUP DATABASE [Production] 
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\Production.bak' 
WITH 
--NOFORMAT, 
INIT,   --<< Specifies that all backup sets should be overwritten 
NAME = N'Production-Full Database Backup', 
--SKIP, 
--NOREWIND, 
--NOUNLOAD, 
COMPRESSION,        --<< Compresses the database
STATS = 10, CHECKSUM  --<< Specifies that the backup operation will verify each page for checksum and torn page
GO

--Verifies that the database backup is valid

declare @backupSetId as int
select @backupSetId = position from msdb..backupset
 where database_name=N'Production' and backup_set_id=(select max(backup_set_id) 
 from msdb..backupset 
 where database_name=N'Production' )
if @backupSetId is null 
begin 
raiserror(N'Verify failed. Backup information for database ''Production'' not found.', 16, 1) 
end
RESTORE VERIFYONLY 
FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\Production.bak' 
WITH  FILE = @backupSetId,  
NOUNLOAD,  
NOREWIND
GO