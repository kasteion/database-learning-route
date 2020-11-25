--Drop database auto
--Drop database auto2


--Create database with default setting based on the Model database configuration

Use master
go

CREATE DATABASE [auto]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'auto', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\auto.mdf' , 
SIZE = 3072KB ,      --<< initial size of data file 3mb      
FILEGROWTH = 1024KB )  --<< growth by 1mg

 LOG ON 
( NAME = N'auto_log', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\auto_log.ldf' , 
SIZE = 1024KB ,    --<< initial size of log file 1mb 
FILEGROWTH = 10%)  --<< growth by 10%
GO

DBCC LogInfo;


--Create database with set LOG FILE setting

CREATE DATABASE [auto2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'auto2', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\auto2.mdf' , 
SIZE = 1024000KB ,       --<< initial size of data file 1000mb 
FILEGROWTH = 102400KB )  

 LOG ON 
( NAME = N'auto2_log', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\auto2_log.ldf' , 
SIZE = 102400KB , 
FILEGROWTH = 102400KB ) --<< growth by 100mb (PRE SIZED SO THAT THE AUTO GROWTH DOES NOT ACTIVATE)
GO

DBCC LogInfo

-- examine the database files

sp_helpdb auto
sp_helpdb auto2

dbcc sqlperf (logspace)

--move data from adventureworks2012 to auto and auto2 dtabase via import/export wizard OR 

Select * Into LogGrowthTable from adventureworks2012.sales.SalesOrderDetai3l


------------------------------------------------------------------------
--RESULTS:

--As the insert is being recored in the transaction log that was 1mb in size, the initial size (1mb) of the tlog recording can't keep up with the
--activity, and as such, needs to expand by 10% each time there is modifications to record.

-- query to find auto growth setting for all or specified database (or use the SQL reports)

USE [master]
GO
 
BEGIN TRY
    IF (SELECT CONVERT(INT,value_in_use) FROM sys.configurations WHERE NAME = 'default trace enabled') = 1
    BEGIN
        DECLARE @curr_tracefilename VARCHAR(500);
        DECLARE @base_tracefilename VARCHAR(500);
        DECLARE @indx INT;
 
        SELECT @curr_tracefilename = path FROM sys.traces WHERE is_default = 1;
        SET @curr_tracefilename = REVERSE(@curr_tracefilename);
        SELECT @indx  = PATINDEX('%\%', @curr_tracefilename) ;
        SET @curr_tracefilename = REVERSE(@curr_tracefilename) ;
        SET @base_tracefilename = LEFT( @curr_tracefilename,LEN(@curr_tracefilename) - @indx) + '\log.trc'; 
        SELECT
            --(DENSE_RANK() OVER (ORDER BY StartTime DESC))%2 AS l1,
            ServerName AS [SQL_Instance],
            --CONVERT(INT, EventClass) AS EventClass,
            DatabaseName AS [Database_Name],
            Filename AS [Logical_File_Name],
            (Duration/1000) AS [Duration_MS],
            CONVERT(VARCHAR(50),StartTime, 100) AS [Start_Time],
            --EndTime,
            CAST((IntegerData*8.0/1024) AS DECIMAL(19,2)) AS [Change_In_Size_MB]
        FROM ::fn_trace_gettable(@base_tracefilename, default)
        WHERE
            EventClass >=  92
            AND EventClass <=  95
            --AND ServerName = @@SERVERNAME
            --AND DatabaseName = 'myDBName'  
			AND DatabaseName IN ('auto','auto2')
        ORDER BY DatabaseName, StartTime DESC;  
    END    
    ELSE   
        SELECT -1 AS l1,
        0 AS EventClass,
        0 DatabaseName,
        0 AS Filename,
        0 AS Duration,
        0 AS StartTime,
        0 AS EndTime,
        0 AS ChangeInSize 
END TRY 
BEGIN CATCH 
    SELECT -100 AS l1,
    ERROR_NUMBER() AS EventClass,
    ERROR_SEVERITY() DatabaseName,
    ERROR_STATE() AS Filename,
    ERROR_MESSAGE() AS Duration,
    1 AS StartTime, 
    1 AS EndTime,
    1 AS ChangeInSize 
END CATCH

--DBCC LogInfo;