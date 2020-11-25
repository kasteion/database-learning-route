--Checks all data in database --8 seconds

DBCC CHECKDB ('adventureworks2012')  --<< in very large databases (VLDB) this may not be an option as it's resource intense
--bus should be done on a prod database, to ge a base line metric

--Specifies that non clustered indexes for non system tables should not be checked

DBCC CHECKDB ('adventureworks2012', NOINDEX) --5 seconds


--Suppresses all informational messages (use in a large database)

Use AdventureWorks2012
GO
DBCC CHECKDB WITH NO_INFOMSGS --<< provides not data except to indicate that the DBCC was successful


--Displays the estimated amount of tempdb space needed to run DBCC CHECKDB (if you want to unload the integrity check to the tempdb)

DBCC CHECKDB ('TEMPDB') WITH ESTIMATEONLY


--This checks physical on-disk structures, but omits the internal logical checks

DBCC CHECKDB ('adventureworks2012') WITH PHYSICAL_ONLY


