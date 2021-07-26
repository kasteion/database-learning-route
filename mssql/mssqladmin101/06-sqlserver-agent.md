# WHAT IS THE SQL SERVER AGENT?

- SQL Server Agent uses SQL Server to store job information.
- A job is a specified series of actions that can run on a local server or on multiple remote servers.
- Jobs can contain one or more other job steps
- SQL Server Agent can run a job on a schedule
- To a response or a specific event or manually
- You can avoid repetitive tasks by automating those tasks
- SQL Server Agent can record the event and notify you via email
- You can set up a job using the SQL Agent for SSIS packages or for Analysis Services
- More than one job can run on the same schedule, and more than one schedule can apply to the same job

## ALERTS

- An alert is an automatic response to a specific event. Which you can define the conditions under which an alert occurs fires.

## OPERATORS

- An operator is the contact person for alerting.

## SECURITY FOR SQL SERVER AGENT ADMINISTRATION

- SQL Agent uses the following msdb database roles to manage security:
    - SQLAgentUserRole
    - SQLAgentReaderRole
    - SQLAgentOperatorRole

## SQL AGENT MULTI SERVER ADMINISTRATION

Using Master / Target server to manage many jobs at once.

# DBCC CHECKDB

The primary purpose is to check both the logical and the physical integrity of all objects in the specified database. In a busy and large production database, it may become necessary to run a few selected options that the DBCC CHECKDB provides.

## COMPLETE SYNTAX OF DBCC CHECKDB

DBCC CHECKDB
    ('database_name'
        [, NOINDEX
            | {REPAIR_ALLOW_DATA_LOSS
                | REPAIR_FAST
                | REPAIR_REBUILD
            }]
    ) [ WITH { [ALL_ERRORMSGS]
        [, [NO_INFOMSGS]]
        [, [TABLOCK]]
        [, [ESTIMATEONLY]]
        [, [PHYSICAL_ONLY]]
    }
]

## DBCC CHECKDB SYNTAX OPTIONS

Checks all data in database --8 seconds

> DBCC CHECKDB ('adventureworks2012')

Specifies that non clustered indexes for non system tables should not be checked. --5 seconds:

> DBCC CHECKDB ('adventureworks2012', NOINDEX)

Suppresses all informational messages (use in large database)

> USE [master]
>
> GO
>
> DBCC CHECKDB WITH NO_INFOMSGS

Displays the estimated amount of tempdb space needed to run DBCC CHECKDB (if you want to unload the integrity check to the tempdb)

> DBCC CHECKDB ('TEMPDB') WITH ESTIMATEONLY

This checks physical on-disk structures, but omits the internal logical checks

> DBCC CHECKDB ('adventureworks2012') WITH PHYSICAL_ONLY

# CONFIGURING AND SETTING UP SQL DATABASE MAIL

Database Mail is an enterprise solution for sending e-mail messages from the SQL Server Database Engine. Using Database Mail, your database applications can send e-mail messages to users. Database Mail is not active by default. To use Database Mail, you must explicitly enable Database Mail by using eithe the Database Mail Configuration Wizzard or sp_configure stored procedure. Once it has been enabled, you can configure SQL mail using either GUI (Wizard) or by script.

After the Account and the Profile are created successfully, we need to configure the Database Mail. To configure it, we need to enable the Database Mail XPs parameter throught the sp_configure stored procedure, as shown here:

```
sp_configure -- Shows the options for server properties (about 69)
GO

sp_configure 'Show Advanced', 1 --Show the options for server properties (about 69)
GO
RECONFIGURE
GO

sp_configure 'Database Mail XPs', 1 --Configure the database mail
GO
RECONFIGURE
GO

sp_configure 'Show Advanced', 0 --Set the options off for server properties
GO
RECONFIGURE
GO
```

When you need to setup Database Mail on dozens of SQL Server instances, use the followin script that saves a lot of time. Below is the template. The sysmail_add_account_sp @username and @password parameters might be required depending on your SMTP server authentication and you will of course need to customize the mail server name and addresses for your environment.

```
-- 1. Enable Database Mail for this instance
EXECUTE sp_configure 'show advanced', 1;
RECONFIGURE;
EXECUTE sp_configure 'Database Mail XPs', 1;
RECONFIGURE;
GO

-- 2. Create a Database Mail Account
EXECUTE msdb.dbo.sysmail_add_account_sp
@account_name = 'Primary Account',
@description = 'Account used by all mail profiles.',
@email_address = 'myaddress@mydomain.com', --enter your email address here
@replyto_address = 'myaddress@mydomain.com', -- enter your email address here
@display_name = 'Database Mail',
@mailserver_name = 'mail.mydomain.com'; -- enter your server name here

-- 3. Create a Database Mail Profile
EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = 'Default Public Profile',
@description = 'Default public profile for all users';

-- 4. Add the account to the profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = 'Default Public Profile',
@account_name = 'Primary Account',
@sequence_number = 1;

-- 5. Grant access to the profile to all msdb database users
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
@profile_name = 'Default Public Profile',
@principal_name = 'public',
@is_default = 1;
GO

-- 6. Send a test email
EXECUTE msdb.dbo.sp_send_dbmail
@subject = 'Test Database Mail Message',
@recipients = 'testaddress@mydomain.com', --enter your email address here
@query = 'SELECT @@SERVERNAME';
GO
```

Database Mail keeps copies of outgoing e-mail messages and other information about mail and displays them ins msdb database using the following scripts:

```
use msdb
go
SELECT * FROM sysmail_server
SELECT * FROM sysmail_allitems
SELECT * FROM sysmail_sentitems
SELECT * FROM sysmail_unsentitems
SELECT * FROM sysmail_faileditems
SELECT * FROM sysmail_mailitems
SELECT * FROM sysmail_log
```

## SENDING EMAIL STORED PROCEDURE

```
EXEC msdb.dbo.sp_send_dbmail
     @profile_name = 'Notifications',
     @recipients = 'Use a valid e-mail address',
     @body = 'The database mail configuration was completed successfully.',
     @subject = 'Automated Success Message';
GO
```
# ALERT: SEVERITY LEVELS

- What are alerts?
- Setting up 17 throught 25 alerts via script
- Mapping alerts to DBA ADMIN operator
- Example of creating an alert for T-LOG Full

Events are generated by SQL Server and entered into the Microsoft Windows application log. SQL Server Agent reads the application log and compares events written there to the alerts that you have defined. When SQL Server Agent finds a match, it fires an alert.

Types of problem:
- Severity level 10 messages are informational
- Severity levels from 11 through 16 are generated by the user
- Severity levels 17 through 25 indicate software or hardware errors
- When a level 17, 18, or 19 errors occurs, you can continue working but check the error log

If the problem affects an entire database, you can use DBCC CHECKDB (database) to determine the extent of the damage.

## SEVERITY LEVEL 17: INSUFFICIENT RESOURCES

These messages indicate that the statement caused SQL Server to run out of resources (such as locks or disk space for the database)

## SEVERITY LEVEL 18: NONFATAL INTERNAL ERROR DETECTED

These messages indicate that there is some type of internal software problem but the statement finishes, and the connection to SQL Server is maintained. For example, a severity level 18 message occurs when the SQL Server query processor detects an internal error during query optimization.

## SEVERITY LEVEL 19: SQL SERVER ERROR IN RESOURCE

These messages indicate that some no configurable internal limit has been exceeded and the current batch process is terminated. Severity level 19 error occur rarely.

## SEVERITY LEVEL 20: SQL SERVER FATAL ERROR IN CURRENT PROCESS

These messages indicate that a statement has encountered a problem. Because the problem has affected only the current process, it is unlikely that the database itself has been damaged.

## SEVERITY LEVEL 21: SQL SERVER FATAL ERROR IN DATABASE (DBID) PROCESS

These messages indicate that you have encountered a problem that affects all processes in the current database; however, it is unlikely that the database itself has been damaged.

## SEVERITY LEVEL 22: SQL SERVER FATAL ERROR TABLE INTEGRITY SUSPECT

These messages indicate that the table or index specified in the message has been damaged by a software or hardware problem.

## SEVERITY LEVEL 23: SQL SERVER FATAL ERROR: DATABASE INTEGRITY SUSPECT

These messages indicate that the integrity of the entire database is in doubt because of a hardware or software problem.

Severity level 23 errors occur rarely; run DBCC CHECKDB to determine the extent of the damage. May be necessary to restore the database.

## SEVERITY LEVEL 24: HARDWARE ERROR

These messages indicaste som type of media failure. The system administrator might have to reload the database. It might also be necessary to call your hardware vendor.

## SETTING UP SQL SERVER AGENT ALERTS

```
USE [msdb]
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 17 Alert',
    @severity=17,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 18 Alert',
    @severity=18,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 19 Alert',
    @severity=19,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 20 Alert',
    @severity=21,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 21 Alert',
    @severity=21,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 22 Alert',
    @severity=22,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 23 Alert',
    @severity=23,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 24 Alert',
    @severity=24,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert 
    @name=N'Error 25 Alert',
    @severity=25,
    @enabled=1,
    @delay_between_responses=0,
    @include_event_description_in=1;
GO
```

## CONFIGURING THE SQL SERVER OPERATOR

```
USE msdb;
GO
EXEC msdb.dbo.sp_add_operator
    @name = 'DBAs',
    @enbled = 1,
    @email_address = 'DBAs@mycompany.com';
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 17 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 18 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 19 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 20 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 21 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 22 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 23 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 24 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Error 25 Alert',
    @operator_name = 'DBAs',
    @notification_method = 1;
GO

```

# WHAT IS MULTI SERVER ADMINISTRATION?

When you have multiple SQL Servers that need the exact same SQL Server Agent Job created or maintenance plans, then rather than creating scirpts and runnign on each server, configure and manage your multiple server vía Central Server Administration option.

This option is very useful when you need to create and run the same jobs or maintenance plans across many SQL Server instances.

## STEPS TO SET UP CENTRAL SERVER MANAGEMENT:

- Register all server in SQL Server Management Studio (SSMS)
- Create Server Groups if necessary for collective administration
- Select multi server administration on SQL Agent and select which SErver should be Master and which should be Targets and follow the wizard.

If this error ocurs (The enlist operation failed reson: SQLServerAgent Error: The target server cannot establish an encrypted connection to the master server 'Server Name'). Make sure that the MsxEncryptChannerOptions registry subkey is set correctly on the target server pops ups, then we have to go to the 'regedit' and configure the registry and change the 'HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\SQLServerAgent and change the MsxEncryptChannerOptions' value to '0'. Save the change and close the Registry editor.

To set up Multi Server Job under SQL Agent you musto connecto to the master server in SSMS and navigate to 'SQL Server Agent' | 'Jobs' | 'Multi-Server Jobs'. Configure the job as needed and on the 'Targets tab' select the target server you want this job to execute on.
