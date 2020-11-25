CREATE DATABASE [Admin]
GO

-- Find recovery mode for each database
-- Excluding system databases. 

SELECT [name], DATABASEPROPERTYEX([name],'recovery') AS RecoveryMode FROM sysdatabases WHERE name NOT IN ('master', 'model', 'tempdb', 'msdb')

-- Change the recovery mode for databases:
USE master;
GO

-- Set recovery model to SIMPLE
ALTER DATABASE Admin SET RECOVERY SIMPLE;
GO

-- Set recovery model to FULL

ALTER DATABASE Admin SET RECOVERY FULL;
GO
