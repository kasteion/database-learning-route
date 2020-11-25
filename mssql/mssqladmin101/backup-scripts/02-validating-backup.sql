--Drop Database Items

Use master
go

-- Create a database

Create Database Items
Go

Use Items 
Go

--Create a table

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

-- Full backup with 6 products 

BACKUP DATABASE items 
TO  DISK = N'c:\fullbackups\items.bak' 
WITH NOINIT,  
NAME = N'items-Full Database Backup', 
COMPRESSION,  
STATS = 10
GO

--Verify that the database backup is valid (not that the data within the database is valid!!!)

declare @backupSetId as int
select @backupSetId = position 
from msdb..backupset 
where database_name=N'items' 
and backup_set_id=(select max(backup_set_id) 
from msdb..backupset where database_name=N'items' )
if @backupSetId is null 
begin 
raiserror(N'Verify failed. Backup information for database ''items'' not found.', 16, 1) 
end
RESTORE VERIFYONLY 
FROM  
DISK = N'c:\fullbackups\items.bak' 
WITH  FILE = @backupSetId
GO

--Insert 2 more rows of data into table

insert into Products values ('Helmit','Shock')
insert into Products values ('Mitts','UnderAmour')

--View data

select * from Products

--Differential backup
--The database must have a full back up in order to take a differential backup; it only backups the changes since last full backup.


BACKUP DATABASE items 
TO  DISK = N'c:\fullbackups\items.bak' 
WITH  DIFFERENTIAL , 
NOINIT, 
 NAME = N'items-Differential Database Backup', 
 COMPRESSION,  
 STATS = 10
GO

--the differnetial backup has captured those TWO additional inserts to the database  (the last two changes since that last full backup)
--Verify that the differntial backup is valid (not that the data within the database is valid!!!)


declare @backupSetId as int
select @backupSetId = position 
from msdb..backupset 
where database_name=N'items' 
and backup_set_id=(select max(backup_set_id) 
from msdb..backupset where database_name=N'items' )
if @backupSetId is null 
begin 
raiserror(N'Verify failed. Backup information for database ''items'' not found.', 16, 1) 
end
RESTORE VERIFYONLY 
FROM  DISK = N'c:\fullbackups\items.bak' 
WITH  FILE = @backupSetId
GO


--Insert 2 more rows of data into table

insert into Products values ('Screen','HP')
insert into Products values ('Ipad','Apple')

--View data

select * from Products


--Transaction Log backup
--You must backup the transaction log, if SQL Server database uses either FULL or BULK-LOGGED recovery model otherwise transaction log is going to full. 
--Backing up the transaction log truncates the log and user should be able to restore the database to a specific point in time.

BACKUP LOG items 
TO  DISK = N'c:\fullbackups\items.bak' 
WITH 
NAME = N'items-Transaction Log  Backup', 
COMPRESSION,  
STATS = 10
GO

--the transaction log backup has captured those TWO additional inserts to the database  (all modification to the database)

declare @backupSetId as int
select @backupSetId = position 
from msdb..backupset 
where database_name=N'items' and backup_set_id=(select max(backup_set_id) 
from msdb..backupset where database_name=N'items' )
if @backupSetId is null 
begin 
raiserror(N'Verify failed. Backup information for database ''items'' not found.', 16, 1) 
end
RESTORE VERIFYONLY 
FROM  DISK = N'c:\fullbackups\items.bak' 
WITH  FILE = @backupSetId
GO



RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\items.bak'

RESTORE LABELONLY FROM DISK = N'c:\fullbackups\items.bak'

RESTORE FILELISTONLY FROM DISK = N'c:\fullbackups\items.bak'

--Backup History
--The following commands provide information as to the history of the backups in the MSDB database.

Use msdb
go

SELECT logical_name, * FROM dbo.backupfile order by 1   -- Contains one row for each data or log file that is backed up 

SELECT * FROM dbo.backupset  -- Contains a row for each backup set
SELECT * FROM dbo.backupmediafamily  -- Contains one row for each media family 
SELECT * FROM dbo.backupmediaset -- Contains one row for each backup media set 
SELECT * FROM dbo.backupfilegroup -- Contains one row for each filegroup in a database at the time of backup 