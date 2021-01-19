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