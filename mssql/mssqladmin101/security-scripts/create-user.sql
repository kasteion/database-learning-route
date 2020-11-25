--Creating a Windows user for SQL Server 

USE [master]
GO

CREATE LOGIN [DBA\tom] --<< Create a SQL Login of Windows user account to access the SQL Server ONLY
FROM WINDOWS 
WITH DEFAULT_DATABASE=[master], 
DEFAULT_LANGUAGE=[us_english]
GO


USE [AdventureWorks2012]
GO
 
CREATE USER [Tom] --<< Create a SQL User using SQL Login to access the database
FOR LOGIN [DBA\tom] --<< SQL Login
WITH DEFAULT_SCHEMA=[dbo]
GO


use [AdventureWorks2012]
GO

GRANT SELECT --<< Grant permission to SQL User to access a table
ON [HumanResources].[Department] 
TO [Tom] AS [dbo]
GO