--the size and number of VLF added at the time of expanding the transaction log is based on this following criteria:
--transaction log size less than 64MB and up to 64MB = 4 VLFs
--transaction log size larger than 64MB and up to 1GB = 8 VLFs
--transaction size log larger than 1GB = 16 VLFs

--1. CREATE A DATABASE WITH LOG FILE LESS THAN 64 MB THAT WILL CREATE 4 VLFS

/*the following will show that improper sizing of the transaction log file and setting and relying on the default auto growth contributes to internal log fragmentation, and causes the VLFS to increase.*/

--Note that the transaction log is 1 megabyte in size, and the autogrowth is set to grow in increments of 10% (bad practice)

CREATE DATABASE [Log Growth]
ON PRIMARY
( NAME = N'LogGrowth', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LogGrowth.mdf' ,
SIZE = 4096KB ,
FILEGROWTH = 1024KB )

LOG ON
( NAME = N'LogGrowth_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LogGrowth_log.ldf' ,
SIZE = 1024KB , --1 megabyte
FILEGROWTH = 10%)
GO

USE [Log Growth]
GO
--Each row indicates a VLF

DBCC LOGINFO
GO

--4 VLFS
--look at the size of the database and note transaction log is 1 MB and data file is 4MB

sp_helpdb [Log Growth]

--Insert data into table from another database and view the transaction log size, data file size, and the percentage of transaction log used

Use [Log Growth]
go

Select * Into LogGrowthTable from adventureworks2012.sales.SalesOrderDetai3l

select count(*) from LogGrowthTable
--log space used 28.7 %

DBCC sqlPerf (LogSpace)
--look at the size of the database and note transaction log is 14 MB and data file is 15MB

sp_helpdb [Log Growth]
--Each row indicates a VLF

DBCC LOGINFO
GO

--47 VLFs created as a result of improper pre sizing of the transaction log, and relying upon the auto growth property to accommodate the expansion of file
--Drop the database

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'LogGrowth'
GO
USE [master]
GO
DROP DATABASE [Log Growth]
GO