# WHAT IS THE SQL PROFILER?

SQL Profiler is a graphical tool that allows the DBAs to monitor events in an instance of Microsoft SQL Server. Once those events and data are captured, you can save the results to a file or a table for later analysis.

## Capabilities of the Profiler

- How to monitor the performance of an instance of SQL Server via trace.
- Review and debug T-SQL statements and stored procedures.
- Identify what is causing slow-executing queries. (Using the Duration Template)
- Audit activity against SQL Server by tracing logins and users (security) (Using the Standard Template).
- Use the tuning template to analyze indexes.
- Add a user profiler template. (Using the tuning template).
- Best practice in using the SQL Profiler.

## DO AND DON'T OF SQL PROFILER

- Since the profiler adds a lot of overhead to production server, filter trace.
- Save the trace to a file rather than a table first.
- Use only when needed for short period of time, as it consumes CPU.
- Configured the trace only relevant events and columns.

## TERMINOLOGY

- **Event**: An event is an action within an instance of SQL Server Database Engine.
- **Trace**: A trace captures data based on the columns and events.
- **Template**: A template defines the default configuration or one that you set for the trace.

# SERVER SIDE TRACE INSTEAD OF SQL PROFILER

## WHAT IS THE SERVER SIDE TRACE?

While the SQL Profiler (Using the GUI) is a great tool, it does come at a cost to performance. To circumvent the resources utilization, we can use the Server side trace to capture the same data as the SQL Profiler. The Server Side Trace actually executes the TSQL scrips on the server rather than using the GUI. And this is a better alternative to the SQL Profiler.

We have to create the trace script from the profiler itself.

The benefits of using SST is that it allows us to monitor:
- Long-running traces
- Reduce network bandwith as the script is executed on the server.
- Can automate the script with a job
- Easy customizable scripts

The server side SQL Trace uses four stored procedures to execute the trace. They are:

- sp_trace_create
- sp_trace_setevent
- sp_trace_setfilter
- sp_trace_setstatus

Here is the site to reviewo in detail the four sprocs:

http://msdn.microsoft.com/en-us/library/ms190362.aspx

To review the SST here are a few TSQL commands:

```
-- Shows you the path, status, ID of the saved SST

SELECT * FROM sys.traces
SELECT * FROM fn_trace_getinfo(default);

Exec sp_trace_setstatus 1, 0 -- 0 = stop trace with id 1
Exec sp_trace_setstatus 1, 2 -- 2 = delete trace with id 1
```

# DATABASE ENGINE TUNING ADVISOR

The Database Tuning Advisor (DTA) is a tool that comes with the SQL Server and is used to analyze a workload and give recomendation that will enhance query performance. The DTA makes recommendations to the following:

- Adding indexes (clustered, non clustered, and indexed views)
- Adding partitioning
- Adding statistics

Note, before we can use the DTA, we must have a workload file to work against. This workload is a collection of data gathered by the SQL Profiler.

You can use direct queries, trace files, and trace tables generated from SQL Server Profiler as workload input when tuning databases.

When you start analysis with Database Engine Tuning Advisor, it analyzes the provided workload and recommends to add, remove, or modify physical design structures in your databases like creating indexes nad partitioning. It also recomends if additional statistics objects need to be created to support physical design.