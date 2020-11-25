-- Demo that taking a full backup does not truncate the log file, but taking a transaction log file does truncate the log file.

-- Drop the current database
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = 'ADMIN'
GO
USE [master]
GO
ALTER DATABASE [ADMIN] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
DROP DATABASE [ADMIN]
GO

-- Create a database for testing
USE MASTER
GO
CREATE DATABASE ADMIN
GO

--Create a table and insert data from AdventureWorks2012.HumanResources.Employee
USE ADMIN
GO
SELECT * INTO dbo.AAA FROM AdventureWorks2012.HumanResources.Employee
SELECT * FROM AAA

-- Change the recovery mode to full so as to take transactional log backups
USE MASTER
GO
ALTER DATABASE ADMIN SET RECOVERY FULL;
GO

USE ADMIN
GO
-- View the space used and allocated to transaction log
DBCC SQLPERF (LOGSPACE);
-- Take a full backup of database
BACKUP DATABASE ADMIN TO DISK='C:\FullBackups\admin.bak';
-- Modify the database by updates, and deletes
USE ADMIN
GO
UPDATE AAA SET MaritalStatus = 'S' WHERE JobTitle='Design Engineer';
DELETE AAA WHERE BusinessEntityID > 5;
-- Take a full database backup to set it in full mode
BACKUP DATABASE ADMIN TO DISK = 'C:\FullBackups\admin.bak';
-- Check the space used by log file after full database backup, notice the log space used had not reduced size!
DBCC SQLPERF(LOGSPACE);
--Take a transaction log backup. Note that the size of the log file space used is reduced, but not the actual size of the file
-- This is because, when you take a log backup, the inactive transactions are removed from the log file to the backup file.
BACKUP LOG ADMIN TO DISK = 'C:\FullBackups\admin.bak'
DBCC SQLPERF(LOGSPACE);
