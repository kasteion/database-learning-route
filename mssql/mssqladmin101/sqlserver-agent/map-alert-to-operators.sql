--Example of creating an alert using the GUI


--USING A WHILE LOOP COMMAND TO POPULATE DATA INTO A TABLE

use Alerts
go

create table WHILE_TABLE 
(FIRSTNAME varchar (8000))
go

declare @i int;
SET @i = 0;
while @i < 1000
begin
	INSERT INTO DBO.WHILE_TABLE (FIRSTNAME)
	VALUES(cast(replicate('DBA',203) AS VARCHAR (20)));
	SET @i = @i + 1;
end;
GO


--creating 17 through 25 severity alerts via TSQL script:

USE [msdb]
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 17 Alert', 
  @message_id=0, 
  @severity=17, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 18 Alert', 
  @message_id=0, 
  @severity=18, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 19 Alert', 
  @message_id=0, 
  @severity=19, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 20 Alert', 
  @message_id=0, 
  @severity=20, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 21 Alert', 
  @message_id=0, 
  @severity=21, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 22 Alert', 
  @message_id=0, 
  @severity=22, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 23 Alert', 
  @message_id=0, 
  @severity=23, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 24 Alert', 
  @message_id=0, 
  @severity=24, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO

EXEC msdb.dbo.sp_add_alert @name=N'Error 25 Alert', 
  @message_id=0, 
  @severity=25, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1;
GO



--mapping alerts to Operators:

USE msdb;
GO

--Create operator DBA_ADMIN

EXEC msdb.dbo.sp_add_operator
  @name = 'DBA_ADMIN',
  @enabled = 1,
  @email_address = 'DBA_ADMIN@mycompany.com'; --<< replace with your email address for the operator
GO 

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 17 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 18 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 19 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 20 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 21 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 22 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 23 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 24 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO

EXEC msdb.dbo.sp_add_notification 
  @alert_name = N'Error 25 Alert',
  @operator_name = 'DBA_ADMIN',
  @notification_method = 1;
GO