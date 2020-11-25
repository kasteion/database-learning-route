# MAINTENANCE PLANS TASKS

## CHECK DATABASE INTERITY PURPOSE

- The DBCC CHECKDB performs an internal consistency check
- Very resource intensive
- Perform it on a regular basis

## SHRINK DATABASE

- Shrinking a database is a very poor practice in the SQL World. Don't do it

## REBUILD INDEX

- The Rebuild index task physically rebuilding indexes from scratch
- This removes index fragmentation and updates statistics at the same time

## REORGANIZE INDEX

- The Reorganize index task helps to remove index fragmentation, bu does not update index and column statistics.
- If you use this option to remove index fragmentation, then you will also need to run the update statistics task as part of the same maintenance plan.

## UPDATE STATISTICS

- The Update Statistics task runs the sp_updatestats system stored procedure against the tables.
- Don't run it after running the Rebuild Index task, as the Rebuild Index task performs this same task automatically.

## EXECUTE SQL SERVER AGENT JOB

- The Execute SQL Server Agent Job task allows you to select SQL Server Agent Jobs (ones you have previously created), and to execute them as part of a Maintenance Plan.

## HISTORY CLEANUP

- The History Cleanup task deletes historical data from the msdb database
- Backup and restore
- SQL Server Agent and Maintenance Plans

## BACKUP DATABASE (FULL)

- The Backup Database (Full) task executes the BACKUP DATABASE statement and creates a full backup of the database.

## BACKUP DATABASE (DIFFERENTIAL)

- The Backup Database (Differential) task executes the BACKUP DATABASE statement using the DIFFERENTIAL option.

## BACKUP DATABASE (TRANSACTION LOGS)

- The Backup Database (Transaction Log) task executes the BACKUP LOG statement, and, in most cases, should be part of any Maintenance Plan that uses the Back Up Database (Full) task

## MAINTENANCE CLEANUP TASK

- Use a batch file to clean up files.

# SHRINKING A DATABASE

The primary purpose of shrinking a database (or individual files) is to reclaim teh space by removing unused pages when a file no longer needs to be as lare as it once was; shrinking the file may then become necessary, but as we will demonstrate, this process is highly discoraged and is an extremely poor practice in the production database environment.

## THINGS TO NOTE

- Both data and transaction log files can be shrunk individually or collectively
- When ussing the DBCC SHRINKDATABASE statement, you cannot shrink a whole database to be smaller than its original size. However, you can shrink the individual database files to a small size than their initial size by using the DBCC SHRINKFILE statement.
- The size of the virtual log files within the log determines the possible reductions in size.
- Shrinking causes massive fragmentation and will just result in the data file growing again next time data gets added. When that happens, the entire system will slow down as the file is expanded.

## AUTOMATIC DATABASE SHRINKING

When the AUTO_SHRINK database option has been set to ON, the Database Engine automatically shrinks databases that have free space. By default, it is set to OFF. Leave it as is.

## DATABASE SHRINKING COMMANDS

- DBCC SHRINKDATABASE(ShrinkDB, 10)
- DBCC SHRINKFILE(ShrinkDB, 10)

## BEST PRACTICES

- Size the database accordingly so as to prevent shrinking and expanding the database.
- When unused space is created due to dropping of tablets, shrinking of the database mya be needed - but rarely.
- Don't constantly shrink the database as it will grow again.
- When you shrink a database, the indexes on tables are not preserved and as such will cause massive fragmentation and will have to be rebuilt.
- Shrinking the log file may be necessary if you log has grown out of control however, shrinking the log should be rare also.
- Regular maintenance plans should never have shrinking database job
- Other issues that shrinking causes are lot of I/O, of CPU usage, and transaction log gets larger - as everything it does is fully logged.

