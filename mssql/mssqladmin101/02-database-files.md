# WHAT IS A DATABASE FILE?

When you create a database, two primary files are created by default: the data file and the transaction log file. The primary purpose of the data file is to hold all the data, such as tables, indexes, store procedures and other relevant data. While the data file is simple to understand and require some management, the transaction log file requires a greater attention and understanding.

# WHAT IS A A TRANSCTION LOG FILE AND ITS PURPOSE?

The primary function of the transaction log file is to: 
- Record all changes to the database
- Record changes sequentially
- All data is written to the transaction log file first before committing the changes to the datafile.
- A triggering mechanism, called a checkpoint, is triggered each few minutes to the transaction log to indicate that a particular transaction has been completely written from the buffer to the data file; this process keeps flushing out the committed transaction, and maintains the size of the physical transaction log file (only in simple recovery mode).
- Key object needed to restore database.
- Controls the size of the transaction log file and prevents the log consuming the disk space.
- Used in log shipping, database mirroring, and replication.
- Allows recover to a point in time.

## REASON THE TRANSACTION LOG FILE IS OUT OF CONTROL IN SIZE

- Transaction log backups are not occurring while in Simple Recovery mode.
- Very long transactions are occurring, like indexes of table or many updates.

## WHAT ARE THE RECOVERY MODELS AND THEIR ROLES?

The recovery models in SQL Server, Simple, Full, Bulk-Logged, determine wheather a transaction log backup is available or not.

**With Simple recovery model**
- Transaction log backups are not supported.
- Truncation of the transaction log is done automatically, thereby releasing space to the system.
- You can loose data, as there are no transaction log backups.
- When in recovery mode, data in the T-Log will not grow.

**With Bulk-Logged recovery model**
- Supports transaction log backups.
- As in Full mode, there is no automated process of transaction log truncation.
- Used primarily for bulk operations, such as bulk insert, thereby minimal.

**Full recovery model**
- Supports transaction log backups
- Little chance of data loss under the normal circumstances
- No automated process to truncate the log thus must have T-log backups
- The transaction log backups must be made regularly to mark unused space available for overwriting.
- When using Full recovery mode, the T-log can get large in size.
- During most backup processes, the changes contained in the log file are sent to the backup file.

View 02-database-files-scripts/01-create-simple-database.sql

View 02-database-files-scripts/02-check-transaction-log.sql

## VIEWING INSIDE THE SQL SERVER DATABASE TRANSACTION LOG TO PREVENT INTERNAL FRAGMENTTION (AUTO GROW AND SIZING OF AUTO GROWTH LOG) 

There is a function called (fn_dblog) which requires a beginning LSN and an ending LSN (Log Sequence Number) for a transaction, but for our purpose we will use NULL as starting an ending values. The following example will show how the transaction log records multiple rows of data for any activity against the database and how a transaction log backup truncates the transaction file, once it's written to the backup log. 

(fn_dblog) A way to view the contents of the log: DO NOT RUN THIS COMMAND IN PRODUCTION AS IT IS UNDOCUMENTED.

```
USE [mater];
GO
CREATE DATABASE VIEWLOG;
GO
--Create tables
CREATE TABLE Cities (Citi varchar(20));
USE VIEWLOG;
GO
BACKUP DATABASE fnlog TO DISK='C:\FullBackups\VIEWLOG.bak';
INSERT INTO CITIES VALUES ('New York');
GO 1000
SELECT COUNT(*) FROM fn_dblog(null, null)
BACKUP DATABASE fnlog TO DISK = 'C:\FullBackups\VIEWLOG.bak';
SELECT COUNT(*) FROM fn_dblog(null, null)
BACKUP LOG fnlog TO DISK = 'C:\FullBackups\VIEWLOG.bak';
SELECT COUNT(*) FROM fn_dblog(null, null)
SELECT * FROM fn_dblog(null, null)
```

Options to truncate the log file:
1. Backup the database.
2. Detach the database
3. Delete the transaction log file. (Or rename the file, just in case)
4. Re-attach the database
5. Shrink the database
6. None of the above

# AUTOGROW

## WHAT IS THE AUTOGROW FEATURE?

Use this query to look inside the transaction log.

```
dbcc loginf
```

By default the transaction log grows by 10%.

An auto-growth event is a part of SQL Server that expands the size of a database file when it runs out of space. I there is a transactions (such as many inserts) that requires more log space than is available, the transaction log file of that database will need to adjusto to the new space needed by increasing the log file size.

## WHAT HAPPENS WHEN AUTO GROWTH IS EXPANDING?

This can cause a performance issue, as this is a blocking operation. The transaction that initiated the log growth will be held until more space is allocated to the log file, determined by the auto growth setting.

Physical fragmentation on the disk occurs as the pages required are not necessarily next to each othe. The more auto-growth events you have the more physical fragmentation you will have.

## AVOID AUTO GROWTH BY PRO ACTIVELY CONFIGURING THE AUTO GROWTH

- Pre-size the data and log files
- Manually manage the growth of data and log files
- Auto growth should be sued for safety reason only

## DON'T RELY ON AUTO GROWTH

- Maintain a level of at least 25 percent available space across disks to allow for growth and peak usage patterns.
- Set the auto-grow settings to grow based on megabytes instead of a percentage, so as to have the auto growth consistent.

## WHAT IS VLF (VIRTUAL LOG FILE)?

The transaciton log is formed by many VLF of the same size. VLF Blocks.
- If you create a log file of 64MB or less, SQL will divide it into 4 VLF.
- If you create a log file of more than 64MB and less than 1G, SQL will divide it into 8 VLF.
- If you crete a log of more than 1G, SQL will divide it into 16 VLF.

```
CREATE DATABASE [LogGrowth]
ON PRIMARY
(NAME = N’LogGrowth’, FILENAME = N’C:\DB\LogGrowth.mdf’, SIZE = 4024KB, FILEGROWTH = 1024KB )
LOG ON (NAME = N’LogGrowth_log’, FILENAME = N’C:\DB\LogGrowth.ldf’, SIZE = 1024KB, FILEGROWTH = 10%)
GO

USE [LogGrowth]
GO

-- This command will give 4 lines because the log is less than 64MB
DBCC LOGINFO
GO

-- Database info
sp_helpdb [LogGrowth]

-- Gives back info about the log file of all databases
DBCC sqlPerf (LogSpace)

```

# THE IMPORTANCE OF TEMPDB

TempDB is a system database that gets created automatically when we install SQL Server or every time the SQL Server service starts.

SQL Server uses TempDB as a workhorse and it can get pretty big. Global Tables and Local temp tables, Temp stored procedure and variables get created here. It can be used to organize an index with SORT_IN_TEMPDB when executing CREATE INDEX releasing the files of the database from this load, and obtaining better perfomace. MARS (Multiple Active Result Sets). Snapshot Isolations y Read-Committed Snapshot Isolation. It's a pretty bussy database and it needs our attention because it can grow a lot if unattended.

We can not drop this database, can not backup this database, can't change the recovery model, can't create multiple file groups, can't detach like a normal database, can't backup or restore this database.

We can configure the datafies and logfiles of this database to be in diferent drives, we can put them in drives with faster IO, predefine auto grow, predefine the size of the files, create multiple files for the tempdb (1 datafile per CPU core), keep the size of the files the same, search for the path of the tempdb and move the tempdb.

# DETACHING AND ATTACHING A DATABASE

## WHAT IS DETACHING AND ATTACHING A DATABASE

The process of moving the data and the log files to anothe drive or server for performance reasons.

## HOW TO USE DETACH AND ATTACH A DATABASE

At times there may be a need to move a database to another physical drive or another physical server, if so, you can use the sprocs detach and attach or use a GUI.

Note: When moving a database using detach and attach, you will lose the users in the original database after the completition of the move to a new server. To resolve this, use the following sproc to link the user to the login in the new server.

```
EXEC sp_change_users_login 'Update_One', 'Bob', 'Bob'
```


