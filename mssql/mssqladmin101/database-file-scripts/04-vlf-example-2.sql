--The following demonstration will illustrate the number of VLF created depending upon the sizing of the transaction log
--Inserting the same amount of data into the table, but this time sizing the transaction log before inserting data by managing the autogrowth size so as to avoid VLFS from being created

--transaction log size larger than 64MB and up to 1GB = 8 VLFs

CREATE DATABASE [Log Growth]
ON PRIMARY
( NAME = N'LogGrowth', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LogGrowth.mdf' ,
SIZE = 1000 MB ,
FILEGROWTH = 100 MB )

LOG ON
( NAME = N'LogGrowth_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\LogGrowth_log.ldf' ,
SIZE = 500 MB , --500 MEGA BYTES - PRE SIZING THE LOG FILE SO AS TO AVOID AUTO GROWTH FROM KICKING IN. AUTOGROWTH SET TO 100 GROWTH RATE AS A FAILSAFE
FILEGROWTH = 100 MB) --file auto growth NOT set to 10%, but allocated 100 in MEGA BYTES
GO

USE [Log Growth]
GO
--Each row indicates a VLF

DBCC LOGINFO
GO

--8 VLFS
--look at the size of the database and note transaction log is 500 MB and data file is 1000

sp_helpdb [Log Growth]

--Insert data into table from another database and view the transaction log size, data file size, and the percentage of transaction log used

Use [Log Growth]
go

Select * Into LogGrowthTable from adventureworks2012.sales.SalesOrderDetai3l

select count(*) from LogGrowthTable

--121317
--log space used 2.504434 %

DBCC sqlPerf (LogSpace)
--Each row indicates a VLF

DBCC LOGINFO
GO

--VLFs have not increased in number as a result of pre sizing the transaction log to 500 MB and therefore having the need to rely on auto growth from kicking in
--Drop the database

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'LogGrowth'
GO
USE [master]
GO
DROP DATABASE [Log Growth]
GO
