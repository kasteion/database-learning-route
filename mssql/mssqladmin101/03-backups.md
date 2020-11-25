# DATABASE BACKUP STRATEGIES

One of the most importante responsabilities of a DBA is the planning, testing and deployment of the backup plan. The planning of the backup strategy, ironically, starts with the restore strategy that has been determined by the organization. Two leading questions direct the restore strategy: What is the maximun amount of data loss that can be tolerated, and what is the accepted tiem frame for the database to be restored in case of disaster. The fist question involves taking multiple transaction logs backups and the second question involves the use of high availability solutions. To answer these question, you must ask the why, what, when, where and who for the strategy.

## WHY BACKUP?

Backups are taken in order to be able to restore the database to its original state just before the disaster and protect against the following reasons:
- hardware failure
- malicious damage
- user-error
- database corruption

## WHAT IS A BACKUP?

Simply put, it's an image of the database at the time of the full backup.

## THERE ARE SEVERAL DIFFERENT KINDS OF BACKUPS

- Full Backup: A complete, page-by-page copy of an entire database including all the data, all the structures and all other objects stored within the database.
- Differential backups - A backup of a database that have been modified in any way since the last full backup.
- Transaction Log - A backup of all the committed transactions currently stored in the transactions log.- Copy-only backup - A special-use backup that is independent of the regular sequence of SQL Server backups.
- File backup - A backup of one or more database files or filegroups.
- Partial backup - Contains data from only some of the filegroups in a database.

## WHEN TO DO BACKUPS?

Again, this is a company decision that must be determined by asking the following questions: What is the maximun amount of data loss that can be tolerated, and what is the accepted time frame for the database to be restored in case of a disaster. The first question will address the use of transaction logs and their frequency, and the second question will involve some type of high availability solution.

## WHERE SHOULD BACKUPS BE PLACED?

Ideally, the backups should be placed on their own drives on separate servers from the production server, and then using a third party application, copies made to a remote server on a separate site. What should not be tolerated is having backups on the same drive and server as the data and log files. If the server crashes, we lose all hopes of restoring critical data!

## WHAT NEEDS BACKING UP

All user defined databases and system databases should be backed up.

## WHO SHOULD PERFORM BACKUPS?

The person in charge of the backup planning and executing will most likely be the Database Administrator (DBA). He will coordinate with the upper management, direct and provide valuable advice on the best practices for restoring the database; however, note that on a production server, most of the backups will be automated by using the SQL Agent and jobs.

## BACKUP RETENTION PERIOD

The amount of backup retained is a question determined by the business needs. Most likely, it may involve a month of backups onsite an three months of backups offsite. But again, this depends upon the organiztion needs.

## FULL DATABASE BACKUP

Backup the whole database, which includes parts of transaction log which is needed to recover the database using full backup.

```
-- Create a test database
use master
go
create database sales
go
use sales
go
create table products (
    ProductID int IDENTITY(1,1) Primary Key,
    ProductName varchar(100),
    Brand varchar(100)
)
go
insert into products values ('Bike', 'Genesis')
insert into Products values ('Hat', 'Nike')
insert into Products values ('Shoes', 'Payless')
insert into products values ('Phone', 'Apple')
insert into products values ('Book', 'Green')
insert into products values ('Cup', 'Large')
select * from products

-- Full backup
BACKUP DATABASE [sales] TO DISK = N'c:\backups\sales.bak'
WITH NOINIT,
NAME = N'sales-Full Database Backup',
COMPRESSION,
STATS = 10
GO

declare @backupSetId as init
select @backupSetId = positin from msdb..backupset where database_name = N'sales'
and backup_set_id = (select max(backup_set_id) from msdb..backupset where database_name =N'sales')
if @backupSetId is null
    begin
        raiserror(N'Verify failed, Backup information for database "sales" not found', 16, 1)
    end
RESTORE VERIFYONLY
FROM 
DISK = N'c:\backups\sales.bak'
WITH FILE = @backupSetId
GO
```

## DIFFERENTIAL BACKUP

The database must have a full backup in order to take a differential backup; in only backups the changes since last full backup.

```
BACKUP DATABASE [sales]
TO DISK=N'c:\backups\sales.bak'
WITH DIFFERENTIAL,
NOINIT,
NAME = N'sales-Differential Database Backup',
COMPRESSION,
STATS = 10
GO
```

## TRANSACTION LOG BACKUP
You must backup the transaction log, if SQL Server database uses either FULL or BULK-LOGGED recovery model otherwise transaction log is going to fill. Backing up the transaction log truncates the log and user should be able to restore the database to a specific point in time.

```
BACKUP LOG [sales]
TO DISK = N'c:\backups\sales.bak'
WITH NAME = N'sales-Transaction Log Backup',
COMPRESSION,
STATS = 10
GO
```

# RECOVERY MODELS

There are three recovery models that can be set on each user database which determines the types of backups you'll use, You set the recovery model vía the GUI or use the ALTER DATABASE command:

```
-- Find the recovery model
SELECT name, recovery_model_desc FROM sys.databases
ALTER DATABASE SALES SET RECOVERY FULL
ALTER DATABASE SALES SET RECOVERY SIMPLE
ALTER DATABASE SALES SET RECOVERY BULK_LOGGED
```

## SIMPLE
When in this mode, the transactions are removed automatically at each checkpoint within the database and no log backups are possible. Recovery to a point in time is not possible and you could lose substantial amounts of data under simple recovery. Not advidsed for production databases that are critical.

## FULL

In full recovery you must run a log backup on a regular basis in order to reclaim log space. Recovery to a point in time is fully supported. For any production system that has data that is vital to the business, full recovery should be used.

## BULK_LOGGED

This recovery model reduces the size of the transaction log by minimally loggin some operations such as bulk inserts. The problem is, recovery to a point in time is not possible with this recovery model because any minimally logged operations cannot be restored. This means that bulk-logged has all the overhead of Full Recovery, but efectively works like simple Recovery. Unless you have specific needs or are willing to perform lots of extra backup operations, it's not recommended to use bulk-logged recovery.

## BACKUP HISTORY

The following commands provides information as to the history of the backups in the MSDB database:

```
USE msdb
GO
-- Contains one row for each data or log file that is backed up
SELECT * FROM dbo.backupfile 
-- Contains one row for each media family
SELECT * FROM dbo.backupmediafamily
-- Contains one row for each backup media set
SELECT * FROM dbo.bakcupmediaset
-- Contains one row for each backup set
SELECT * FROM dbo.backupset
-- Contains one row for each filegroup in a database at the time of backup
SELECT * FROM dbo.backupfilegroup
```

## BACKUP FILE INFORMATION

It is possible to look at a backup file itself to get information about the backup, the header of the backup stores data like when the backup was created, what type of backup it is, the user who took the backup and all other sorts of information. The basic commands availables are:

```
RESTORE LABELONLY FROM DISK = N'c:\bakups\sales.bak'
RESTORE HEADERSONLY FROM DISK = N'c:\backups\sales.bak'
RESTORE FILESLISTONLY FROM DISK = N'c:\backups\sales.bak'
```
## BASIC BACKUP PROCESS

The following backup schedule is one that used on a prodcution server for critical databases.

- Sunday Night: Full Backup with database consistency check (DBCC CHECKDB)
- Monday-Saturday: Differential Backup each day
- Midnight-11:45pm: Log Backup every 30 minutes

What is important to understand is that you frequently test your backups with restores, at least once a month, to ensure that your backups are valid and restorable. Having bakcups is useless unless they have been tested well. When backing up database, starting with SQL version 2008 and up, you have the ability to compress the database backup. Note that the CPU resource will consume about 20% additional resource, thus, the backup must be done in the off hours.

## EXAMPLE OF BACKUP PLAN USING DIFFERENT TYPES OF BACKUPS
- 12:00 am: Create an empty database (20gigs)
- 12:14 am: Full backup
- 12:30 am: Insert 100,000 rows (1gig)
- 12:45 am: Differential backup (size 1 gig after diff)
- 01:00 am: Insert 100,000 rows (1gig)
- 01:15 am: Differential backup (size 2 gig after diff)
- 01:30 am: Insert 100,000 rows (1gig)
- 01:45 am: Transactional log (size 4 gigs after t-log)
- 02:00 am: Insert 100,000 rows (1gig)
- 02:15 am: Transactional log (size 5 gigs after t-log)

## RESTORE PROCESS

- 12:15 am: Full backup
- 01:15 am: Differential backup (size 3 gig after diff)
- 01:45 am: Transactional log (size 4 gigs after t-log)
- 02:15 am: Transactional log (size 5 gigs after t-log)

# BACKUP STRATEGY FOR VARIOUS SCENARIOS

## The manager wants you to create a backup strategy for the following conditions:

- It's a test database
- It's a small database (1gig)
- Must have full backups
- Can recreate data in a short time
- Not to much activity during week

**Solution**
- Select Simple Recovery Mode

## The manager wants you to create a backup strategy for the following conditions:

- It's a production database
- It's a midsize database (20 gigs)
- Must have backup backups
- Cannot recreate data in a short time
- Daily activity during week
- Restore must be within 1 day

**Solution**

- Take a full database backup weekly
- Select full recovery mode
- Create hourly transaction log backups
- Create differential backups each six hours

# The manager wants you to create a backup strategy for the following conditions:

- It's a production database
- It's a large database (200gigs)
- Must have full backups
- Cannot recreate data in a short time
- Daily intense activity during the week
- Restore must be within 3 hours

**Solution**

- Take a full database backup Monday, Wednesday, Friday.
- Select Full recovery Mode
- Create 15 min transaction log backups
- Create differential backpus each 3 hours
