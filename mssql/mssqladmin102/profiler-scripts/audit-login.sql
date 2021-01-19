
---- Audit login Tom to see what he is doing??

----Before creating a SQL Login, make user the that authentication is set to mixed mode.  will need to restart services

----Create a SQL Login for Tom

--USE [master]
--GO

--CREATE LOGIN [Tom] WITH PASSWORD=N'password123', 
--DEFAULT_DATABASE=[master], 
--CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
--GO

--USE [SQL2]
--GO

--CREATE USER [Tom] FOR LOGIN [Tom]
--GO

--USE [SQL2]
--GO

--ALTER ROLE [db_owner] ADD MEMBER [Tom] --<< Tom is a the databasse owner as such has
--GO


SELECT TOP 1000 [RowNumber]
,[EventClass]
,[Duration]
,[TextData]
,[SPID]
,[BinaryData]
FROM [SQL2].[dbo].[duration]-- 10 rows

--Create a backup of duration table

select * into duration013016 from duration

 

--Audit deleted rows from login Tom using the profiler (find the sql statements against the database)

delete from duration where RowNumber = 6



/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [RowNumber]
      ,[EventClass]
      ,[TextData]
      ,[ApplicationName]
      ,[NTUserName]
      ,[LoginName]
      ,[SPID]
      ,[BinaryData]
  FROM [SQL2].[dbo].[audit]
  where loginname = 'tom' and textdata like '%delete%'
