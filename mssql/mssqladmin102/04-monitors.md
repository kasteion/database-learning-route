# ACTIVITY MONITOR IN SQL SERVER

The primary function of the Activity Monitor is to Allow the DBA to quickly view any potential performance issues in the server, network or the database. If any contentions are occurring between SPIDs, this is where the DBA can kill the process.

Viewing the Activity Monitor Dashboard you will notice four graphs which can help identity any abnormal activity in the Database. Note that the refresh rate for each graph is 10 seconds; however it can be changed by right clicking on the graph.

% Processes Time | Waiting Taks | Database IO | Batch Request/s

This dashboard also contains four panes where you can view more detailed information about each process inside the server.

## PROCESSOR TIME

The processes pane gives information on what processes are running and what resources are being utilized etc. You can right click this and view the Kill, Profiler, and Details options.

## WAITING TASKS

The number of tasks that are waiting for processor, I/O, or memory resources. The Resources Waits pane details the processes waiting for other resources on the server.

## DATABASE I/O: (INPUT/OUTPUT)

Information on data and log files for both system and user defined databases. Provides information on such things as the transfer rate in MB/Sec, data from memory to disk, disk to memory, or disk to disk. this allows the DBA to quickly view what is causing I/O contention.

## BATCH REQUEST/SEC:

This pane shows the number of batches being received, Expensive queries running, and find the most time consuming code in your SQL Server Database. If you right click this pane, you can view the execution plan option.

## THE VARIOUS PANES INFO

The processes pane shows the information about the currently running processes on the SQL database, who runs them, and from which application. Hover over each header to show tool tips.

- **Session ID**: or SPID is a unique value assigned by Database Engine to every user connection.
- **User Process**: 1 for user processes, 0 for system processes.
- **Task State**: The task state, blank for tasks in the runnable and sleeping state.
    - **PENDING**: Waiting for a worker thread.
    - **RUNNABLE**: Runnable, but waiting to receive a quantum.
    - **RUNNING**: Currently running on the scheduler.
    - **SUSPENDED**: Has a worker, but is waiting for an event
    - **DONE**: Completed
    - **SPINLOOP**: Stuck in a spinlock.
- **Wait Time(ms)**: How logn in millisecond the task is waiting for a resource.
- **Wait Type**: The last/current wait type.
- **Wait Resource**: The resource the connection is waiting for.
- **Blocked By**: The ID of the session that is blocking the task.
- **Head Blocker**: The session that causes the first blocking condition in a blocking chain.
- **Memory Use(KB)**: The memory used by the task.
- **MB/sec Read**: Shows recent read activity for the database file.
- **MB/sec Written**: Show recent write activity for the database file.
- **Response Time (ms)**: Average response time for the recent read-and-write activity.

## THE RECENT EXPENSIVE QUERIES PANE

Expensive queries are the queries that use much resources - memory, disk, and network.

- **Executions/min**: The number of execution per minute, since the last recompilation.
- **CPU (ms/sec)**: The CPU rate used, since the last recompilation.
- **Physical Read/sec, Logical Writes/sec and Logical Reads/Average**
- **Duration (ms)**: Average time that the query runs.

# WHAT IS THE (SQL) PERFORMANCE MONITOR?

Windows Performance Monitor or PerfMon is a great tool to capture metrics for your entire Windows server and including your SQL Server environment. It has easy to view graphs and counters that you can select to find a specific issue at hand.

There are counter for .NET, Disk, Memory, Processors, Network, and many for SQL Server realated to each instance of SQL Server that you may have on the box.

The purpose of the `perfmon` is to identify the metrics you like to use to measure SQL Server performance and collectiong them over time giving you a quick and easy way to identify SQL Server problems, as well as capture you performance trend over time.

## WHAT ARE COUNTERS, WHAT COUNTERS SHOULD WE USE?

Counters are a method to measure current performance, as well as performance over time. As there are many counters and there is no strict guideline as to use a specific counter, I suggest we look at some common ones for our demonstration an the allow the DBA to experiment with others. The best approach is to capture some common values when your system is running fine, so you can create a baseline. Then once you have information about these counters and the baseline you can compare performance issues against the baseline.

Measuring Windows counters Example:

- **Memory**: Available MBytes
- **Paging File**: % Usage
- **Physical Disk**: Avg. Disk sec/Read
- **Physical Disk**: Avg. Disk sec/Write
- **Physical Disk**: Disk Reads/sec
- **Physical Disk**: Disk Writes/sec
- **Processor**: % Processor time
- **Network**

Measuring SQL Server counters:

- **SQLServer: Buffer Manager: Buffer cache hit ratio**: The buffer cache hit ration counter represents how often SQL Server is able to find data pages (smalles unit of data 8k) in its buffer cache when a query needs a data page. We want this number to be as close to 100 as possible, which means that the SQL Server was able to get data for queries out of memory instead of reading from disk. A low number indicates a memory issue.
- **SQLServer: Buffer Manager: Page life expectancy**: The page life expenctancy counter measures how long pages stay in the buffer cache in seconds. The longer a page stays in memory, the better as this indicates that the SQL Server doesn't need to read from disk. A lower number indicates that it's reading from disk. Add more memory?
- **SQLServer: SQL Statistics: Batch Requests/sec**: Batch Requests/Sec measures the number of batches SQL Server is receiving per second. This information provides how much activity is being processed by your SQL Server box. The higher the number, the more queires are being executed on your box. Higher number indicates that the server is busy. But, again create a baseline for your system.
- **SQLServer: SQL Statistics: SQL Compilations/sec**: The SQL Compilations/Sec measure the number of times SQL Server compiles an execution plan per second. Compiling an execution plan is a resource/intensive operation. One compilate per every 10 batch requests.
- **SQLServer: Locks: Lock Waits / Sec: _Total**: In order for SQL Server to manage concurrent users on the system. SQl Server needs to lock resources from time to time. The lock waits per second counter tracks the number of times per second that SQL Server is not able to retain a lock right away for a resource. Ideally you don't want any request to wait for a lock. Therefore you want to keep this counter at zero, os close to zero at all times.
- **SQLServer: Access Methods: Page Splits/Sec**: This counter measures the number of times SQL Server had to split ta page when updating or inserting data per second. Page splits are expensive, and cause your table to perform more poorly due to fragmentation. Therefore, the fewer page splits you have the better your system will perform. Ideally this counter should be less than 20% of the batch request per second.
- **SQLServer: General Statistics: User Connection**: The user conncections counter indetifies the number of different users that are connected to SQL Server at the time the sample was taken. This does not refer to the end users, but rather connection that a suer has to the server. A user can have many connection.
- **SQLServer: General Statistics: Processes Block**: The processes blocked counter identifies the number of blocked processes. When one process is blocking another process, the blocked process cannot move forward with its execution plan until the resource that is causing it to wait is freed up. Ideally you dont't want to see any blocked processes. When processes are being blocked you should investigate.
- **SQLServer: Buffer Manager: Checkpoint Pages / Sec**: The checkpoint pages per second counter measures the number of pages written to disk by a checkpoint operation. If this counter is climbing, it might mean you are running into memory pressures that are causing dirty pages to be flushed to disk more frequently than normal.

# BOTTLENECKS

One of the prime purpose of the perfmon is to discover bottlenecks. Thus, we must first understand what is a bottleneck?

A bottleneck occurs when simultaneous access BY APPLICATION OR USERS to shared resources such as (CPU, memory, disk, network or other resources) causes an overload for the resources. This demand on shared resources can cause poor response time and must be identified and tuned by the DBA. The tuning can be either hardware upgrade, application tuning or both. Monitoring SQL Server performance is a complex task, as performance depends on many parameters, both hardware and software.

What causes bottlenecks:

- Inssufficient hardware resources which may require upgrade or replacement.
- Resources are not distributes evenly; an example being one disk is being monopolized.
- Incorrectly configured resources such as applications or ill designed databases.

Some of the key areas to monitor to identify bottlenecks are as follows:

- CPU utilization
- Memory usage
- Disk input/output (I/O)
- User connections
- Blocking locks

Before going out and buying a faster server or upgrading the existing server with faster CPUs, more memory and faster disks, obtain a baseline of metrics. And always rule out software issues first such as poorly designed databases and insufficient idexes.

## START WITH OBTAINING A PERFORMANCE BASELINE

You monitor the server over time so that you can determine Server average performance, identify peak usage, determine the time required for backup and restore activities, and so on. This gives you a baseline from which you can judge the server against to determine if you have a performance bottleneck. this may be a weekly or monthly set of metrics that you obtain. Each depends upon your environment.

## HARDWARE BOTTLENECKS

Most hardware bottlenecks can be attributed to disk throughput, memory usage, processor usage, or network bandwidth.

One problem can often mask another. You might suspect hard disk performance as the cause of degraded query performance.

You can sometimes relieve bottlenecks by rescheduling resource-intensive SQL Server activities so that there's less of a load on the server.

One area you should check is the performance of queries.

If you have queries that use excessive server resources, overall performance suffers.

SQL Profiler and the Database Engine tuning Advisor can both help you gather information about queries.

**CPU Utilization**

- A chronically high CPU utilization rate may indicate that Transact-SQL queries need to be tuned or that a CPU upgrade is needed. CPU usage greater than 80$ consistently (plateauing)

**Memory Usage**

- Insufficient memory allocated or available to Microsoft SQL Server degrades performance. SQL Server is a hog for memory and the more memory the better. If sufficient memory is not allocated to the SQL Server, then Data must be read from the disk rather than directly from the data cache. This can cause performance issues.

**Disk input/output (I/O)**

- Transact-SQL queries can be tuned to reduce unnecessary I/O; for example, by employing indexes.

**User Connections**

- To many users may be accessing the server simultaneously causing performance degradation.

**Blocking locks**

- Incorrectly designed applications can cause locks and hamper concurrency, thus causing longer response times and lower transaction throughput rates.

## MONITORING PROCESSOR USE

High processor utilization can be an indication that: 
1. You need a processor upgrade (faster, better processor).
2. You need an additional processor.
3. You have a poorly designed application.

By monitoring processor activity over time, you can determine if you have a processor bottleneck and ofter identify the activities placing an excessive load on the processor.

Counters that you shold monitor include these:

- Procesor - % Processor Time: Value should be consistently less than 90%. A consistent value of 90% or more indicates a processor bottleneck. Monitor this for each processor in a multiprocessor system and for total processor time (all processor).
- System - Processor Queue Length: The number of threads waiting for processor time. A consistent value of 2 or more can indicate a processor bottleneck.

In most cases, a processor bottleneck indicates you need to either upgrade to a faster processor or to multiple processors. In some cases, you can reduce the processor load by fine-tuning you application.

## MONITORING SQL SERVER MEMORY USAGE

- Memory: Available MBytes
- Memory: Pages / sec
- Memory: Pages Faults / sec

Available MBytes is the amount of physical memory, in Megabytes, immediately available for allocation to a process or for system use. The higher the value the better.

The Pages/sec counter indicates the number of pages that were retrieved from disk. A high value can indicate lack of memory.

Monitor the Memory: Page Faults / sec counter to make sure that the disk activity is not caused by paging.

By default, SQL Server changes its memory requirements dynamically so there is no need to alter the memory parameters; but if you need to alter the memory, you can change that via GUI or TSQL.

To monitor the amount of memroy that SQL Server specifically uses monitor:
- SQL Server: Buffer Management: Buffer Cache Hit Ratio
- SQL Server: Memory Management: Total Server Memory (KB)
- SQL Server: Buffer Management: Page Life Expectancy

The Buffer Cache Hit Ratio counter is specific to SQL Server; Percentage of pages that were found in the buffer pool without having to incur a read from disk. A rate of 90 percent or higher is desirable. A value grater than 90 percent indicates that more than 90 percent of all requests for data were satisfied from the data cache rather than the disk.

If the Total Server Memory (KB) counter is consistently high compared to the amount of physical memory in the computer, it may indicate that more memory is required.

Page Life Expectancy is the number of seconds a page will stay in the buffer pool without references. The recommended value of the Page Life Expectancy counter is approximately 300 seconds. Simply put, the longer the page stays in the buffer the beter performance you will get rather than getting data from the disk.

## MONITORING DISK PERFORMANCE

Some common counters used for analyzing disk performance are:

- Avg. Disk sec/Read: The Average time, in seconds, of a read of data from the disk.
- Avg. Disk sec/Write: Is the average time in seconds, of a write of data to the disk.

These metrics help how long the disks took to service an I/O request no matter what kind of hardware you using, wather its physical or virtual hardware. If your system had many disks, then it's important to measure each disk for discovering bottlenecks.

The average should be under 15ms with maximums up to 30ms. The less time it takes to read or write data the faster you system will be.

- Disk Transfers/sec: Is the rate of read and write operations on the disk.
- Disk Reads/sec: Is the rate operations on the disk.
- Disk Writes/sec: Is the rate of write operations on the disk.
- Avg. disk Queue Length: Is the average number of both read and write requests that were queued for the selected disk during the sample interval.
- Current Disk Queue Length: Is the number of requests outstanding on the disk at the time the performance data is collected.

# WHAT ARE DYNAMIC MANAGEMENT VIEWS (DMVs)

Another tool at your disposal to measure performance and view details about the SQL Server is the DMVs. Dynamic management views and functions return server state information that can be used to monitor the health of a server instance, diagnose problems, and tune performance.

There are two different kinds of DMVs and DMFs:

- Server Scoped: These look at the state of an entire SQL Server instance.
- Database-Scoped: These look at the state of a specific database.
- While the DMV can be used like the select statement, the DMF requires a parameter.
- Some apply to entire server and are stored in the master database while others to each database.
- Over 200 DMVs at this time.

The DMVs are broken down into the following categories:

- Change Data Capture Related Dynamic Management Views.
- Change Tracking Related Dynamic Management Views.
- Common Language Related Dynamic Management Views.
- Database Mirroring Related Dynamic Management Views.
- Database Related Dynamic Management Views.
- Execution Related Dynamic Management Views.
- Extended Events Dynamic Management Views.
- Full-Text Search Related Dynamic Management Views.
- Filestream-Related Dynamic Management Views (Transact-SQL)
- I/O Related Dynamic Management Views and Functions.
- Index Related Dynamic Management Views and Functions.
- Object Related Dynamic Management Views and Functions.
- Query Notifications Related Dynamic Management Views.
- Replication Related Dynamic Management Views.
- Resource Governor Dynamic Management Views.
- Service Broker Related Dynamic Management Views.
- SQL Server Operating System Related Dynamic Management Views.
- Transaction Related Dynamic Management Views.
- Security Related Dynamic Management Views.