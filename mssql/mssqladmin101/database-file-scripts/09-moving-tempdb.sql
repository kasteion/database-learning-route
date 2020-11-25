--find the path to tempdb

sp_helpdb tempdb

-- name		 filename
--tempdev		C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\tempdb.mdf
--templog		C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\templog.ldf

--To change the tempdb location use the following script:

USE master;
GO

ALTER DATABASE tempdb
MODIFY FILE
(NAME = tempdev, FILENAME = 'C:\tempdbnewlocation\Tempdb.mdf');
GO

ALTER DATABASE tempdb
MODIFY FILE
(NAME = templog, FILENAME = 'C:\tempdbnewlocation\Tempdb.ldf');
GO

sp_helpdb tempdb


USE master;
GO

ALTER DATABASE tempdb
MODIFY FILE
(NAME = tempdev, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\tempdb.mdf');
GO

ALTER DATABASE tempdb
MODIFY FILE
(NAME = templog, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\templog.ldf');
GO

sp_helpdb tempdb


--cant change the recovery model

USE [master]
GO
ALTER DATABASE [tempdb] SET RECOVERY FULL 
GO

--Sizing the data and log files and autogrowth property

USE [master]
GO
ALTER DATABASE [tempdb] 
MODIFY FILE ( NAME = N'tempdev', SIZE = 102400KB , FILEGROWTH = 20480KB )--<< pre sizing data, auto growth

GO
ALTER DATABASE [tempdb] 
MODIFY FILE ( NAME = N'templog', SIZE = 20480KB , FILEGROWTH = 20480KB )--<< pre sizing log, auto growth
GO