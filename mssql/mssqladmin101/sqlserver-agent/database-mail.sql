-- 1. Enable Database Mail for this instance

EXECUTE sp_configure 'show advanced', 1;
RECONFIGURE;
EXECUTE sp_configure 'Database Mail XPs',1;
RECONFIGURE;
GO

-- 2. Create a Database Mail account

EXECUTE msdb.dbo.sysmail_add_account_sp
@account_name = 'SQL',
@description = 'Account used by all mail profiles.',
@email_address = 'rafasg61@msn.com', -- enter your email address here
--@replyto_address = 'rafasg61@msn.com', -- enter your email address here (note reply has been commented out as i had issues with setting up msn account)
@display_name = 'Database Mail',
@mailserver_name = 'smtp.live.com'; -- enter your server name here

--3. Create a Database Mail profile

EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = 'Default Public Profile',
@description = 'Default public profile for all users';

-- 4.Add the account to the profile

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = 'Default Public Profile',
@account_name = 'SQL',
@sequence_number = 1;

-- 5.Grant access to the profile to all msdb database users

EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
@profile_name = 'Default Public Profile',
@principal_name = 'public',
@is_default = 1;
GO

--6.send a test email

EXECUTE msdb.dbo.sp_send_dbmail
@subject = 'Test Database Mail Message',
@recipients = 'rafasg61@msn.com', -- enter your email address here
@query = 'SELECT @@VERSION'; -- gives you the version of SQL

GO

--view information about mail in msdb database using the following scripts:
use msdb
go


SELECT * FROM sysmail_server
SELECT * FROM sysmail_allitems 
SELECT * FROM sysmail_sentitems
SELECT * FROM sysmail_unsentitems 
SELECT * FROM sysmail_faileditems 
SELECT * FROM sysmail_mailitems
SELECT * FROM sysmail_log