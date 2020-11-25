--Drop database BackupDatabase

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'BackupDatabase'
GO
USE [master]
GO
/****** Object:  Database [BackupDatabase]    Script Date: 10/24/2015 4:13:34 PM ******/
DROP DATABASE [BackupDatabase]
GO


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

insert into Products values ('motor','chevy')
insert into Products values ('Hat','Nike')
insert into Products values ('Shoe','Payless')
insert into Products values ('Phone','Apple')
insert into Products values ('Book','Green')
insert into Products values ('Cup','Large')


--Take full database backup of six rows

BACKUP DATABASE [BackupDatabase] 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH NOINIT,  --<< No override
NAME = N'BackupDatabase-Full Database Backup', 
STATS = 10
GO

--1
Insert into Products values ('Doll','Toy_R_us')

BACKUP LOG BackupDatabase 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH 
NAME = N'BackupDatabase-Transaction Log  Backup', 
STATS = 10
GO

--2
Insert into Products values ('House','Remax')

BACKUP LOG BackupDatabase 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH 
NAME = N'BackupDatabase-Transaction Log  Backup', 
STATS = 10
GO

--3
Insert into Products values ('Car','Porche')

BACKUP DATABASE [BackupDatabase] 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  DIFFERENTIAL , 
NOINIT,  
NAME = N'BackupDatabase-Differential Database Backup',   
STATS = 10
GO

--4
Insert into Products values ('Chair','Walmart')

BACKUP LOG BackupDatabase 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH 
NAME = N'BackupDatabase-Transaction Log  Backup', 
STATS = 10
GO

--5
Insert into Products values ('Mouse','Apple')

BACKUP LOG BackupDatabase 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH 
NAME = N'BackupDatabase-Transaction Log  Backup', 
STATS = 10
GO

--6
Insert into Products values ('TV','Sony')

BACKUP DATABASE [BackupDatabase] 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  DIFFERENTIAL , 
NOINIT,  
NAME = N'BackupDatabase-Differential Database Backup',   
STATS = 10
GO

--7
Insert into Products values ('Phone','Apple')

BACKUP LOG BackupDatabase 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH 
NAME = N'BackupDatabase-Transaction Log  Backup', 
STATS = 10
GO

--Look insde the .bak file
--RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--SELECT * FROM Products --13 ROWS

-- INSERTS HAPPENED HERE BUT NOT BACKUP

Insert into Products values ('DESK','IKEA')
Insert into Products values ('LAMP','SUMMERS')
Insert into Products values ('PENS','BIGGS')
Insert into Products values ('PILLOW','SAMS')

--SELECT * FROM Products --17 ROWS

--DATABASE IS CORRUPT!  NEED TO RESTORE ASAP  (HOW DO YOU GET THE LAST INSERTS)
--TAKE A TAIL LOG IF POSSIBLE!!

--AT THIS POINT, IF I WERE TO RESTORE THE DATABASE WITH POSTION 1, 7 AND 8, I WOULD RETRIVE 13 ROWS, NOT 17.  THUS I NEED TO TAKE TAIL LOG BACKUP IF POSSIBLE

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'


--BEFORE RESTORING THE DATABASE, TAKE A LAST TAIL-LOG BACKUP IF POSSIBLE WITH NORECOVERY OPTION TO GRAB THE LAST FOUR INSERTS
use master
go

BACKUP LOG [BackupDatabase] 
TO  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  NO_TRUNCATE ,  --<< must have the NO_TRUNCATE option set, so as not to delete the remaining four inserts
COPY_ONLY,           --<< also, have the option COPY_ONLY so as not to break the chain of sequential t-logs of the backup set
NOFORMAT, NOINIT,  
NAME = N'BackupDatabase-Transaction Log  Backup', 
SKIP, NOREWIND, NOUNLOAD,  
NORECOVERY ,  STATS = 10 --<< this norecovery option puts the database in to restoring mode
GO

--sp_who kill 54


--THEN RESTORE THE DATABASE USING THE FOLLOWING SCRIPT IN ORDER (FULL, LAST DIFF, ALL T-LOGS)

RESTORE DATABASE [BackupDatabase] 
FROM  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  FILE = 1,  
NORECOVERY,  
NOUNLOAD,  
STATS = 5

RESTORE DATABASE [BackupDatabase]               --<<last diferential
FROM  DISK = N'c:\fullbackups\BackupDatabase.bak' 
WITH  FILE = 7,  
NORECOVERY,  
NOUNLOAD,  
STATS = 5

RESTORE LOG [BackupDatabase] 
FROM  
DISK = N'c:\fullbackups\BackupDatabase.bak'
WITH  FILE = 8,  
NOUNLOAD, 
NORECOVERY, 
STATS = 5
GO

--tail log restore
RESTORE LOG [BackupDatabase] 
FROM  
DISK = N'c:\fullbackups\BackupDatabase.bak'
WITH  FILE = 9,  
NOUNLOAD,  
STATS = 5
GO
