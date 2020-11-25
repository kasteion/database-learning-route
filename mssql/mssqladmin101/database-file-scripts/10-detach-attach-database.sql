--The following scripts will detach and then reattach the sales database

--Find the path of the database

sp_helpdb sales

--Set the database to a single user mode

USE [master]
GO

ALTER DATABASE [Sales] 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

--Detach the database using the sprocs

USE [master]
GO

EXEC master.dbo.sp_detach_db @dbname = N'Sales', @skipchecks = 'false'
GO



--Reattach the database using the FOR ATTACH command 
--(Note we do not use the depricated sp_attach_db to attach a database, but instead use the code below using FOR ATTACH)

USE [master]
GO
CREATE DATABASE [Sales] ON 
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Sales.mdf' ),
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Sales_log.ldf' )
 FOR ATTACH --<<use for attach to attach the sales database
GO