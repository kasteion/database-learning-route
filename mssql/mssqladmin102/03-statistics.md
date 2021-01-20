# SQL SERVER STATISTICS AND THE ROLE IT PLAYS

A query is a request for information from a database; this can be either a simple request or a complex request such as using joins.

Since database structures are complex and the need to access the data can be achieved in different ways, (such as a table scan or use of an index) the processing time to get that data may vary and SQL may need 'help' to retrieve that data. **Statistics** in SQL Server refers specifically to information that the server collects about the distribution of data in columns and indexes.

This is where the **query optimizer** comes in. Note, the query optimizer cannot be accessed directly by user, but the query optimizer attemps to determine the most efficient way to execute a given query by considering the possible query plans, such as using a table scan or the number of records, density of pages, histogram, or available indexes all help the SQL Server optimizer in 'gessing' the most efficient way to retrieve data.

Thus query optimization typically tries to approximate the optimun processing time ti will take to retrieve the data request.

# SO HOW ARE STATISTICS CREATED?

Statisctis can be automatically created when you create an index. if the datbase setting auto creates stats is on, then SQL Server will automatically create statistics for non-indexed collumns that are used in queries.

Or they can be manually created by TSQL or GUI.

```
USE [AdventureWorks2014]
GO

CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160203-192425] 
ON [dbo].[People2] ([Fname] ASC, [Lname] ASC)

DBCC SHOW_STATISTICS ('People2', 'NonClusteredIndex-20160203-192425') WHITH HISTOGRAM
```
# HOW ARE STATISTICS UPDATED?

The default setting in SQL Server are to auto create and auto update statistics.

**Auto Update Statistics** basically means, if there is an incoming query but statistics are stale, SQL Server will update statistics first before it generates an execution plan.

**Auto Update Statistics Asynchronously** on the other hand menas, if there is an incoming query but statistics are stale, SQL Server uses the stale statistics to generate the execution plan, then updates the statistics afterwards.

What configuration settings should we set?

**Automatic Statistics**

By default, SQL Server databases automatically create and update statistics. The information that gets stored includes:

- The number of rows and pages occupied by a table's data
- The time that statistics were last updated
- The average length of keys in a column
- Histograms showing the distribution of data in a column

