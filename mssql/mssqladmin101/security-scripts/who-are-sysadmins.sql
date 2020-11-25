--Who are the sysadmins in this sql server?

--04/23/2012 by Marlon Ribunal | 10 Comments

--Here’s a quick query that you can run to find out the users with sysadmin fixed server role. Sysadmins have a complete control of your server. So, it is very important to know who these people are.

--Just to give you an example on why it is very important to check who’s who in your server from time to time, Team Shatter has recently published an advisory on Privilege Escalation Via Internal SQL Injection In RESTORE DATABASE Command.

--According to the advisory, there is a vulnerability in the RESTORE DATABASE command that allows malicious users to run SQL codes via internal sql injection. This vulnerability can be exploited by users with CREATE DATABASE permission.

--A rogue user can find his way to taking control over your databases by using a backdoor such as the vulnerability described above. Imagine the same user was able to add himself to a server-wide role such as the sysadmin.

--So, going back to the query, here is what it looks like:

	
USE master
GO
 
SELECT  p.name AS [loginname] ,
        p.type ,
        p.type_desc ,
        p.is_disabled,
        CONVERT(VARCHAR(10),p.create_date ,101) AS [created],
        CONVERT(VARCHAR(10),p.modify_date , 101) AS [update]
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%'
        -- Logins that are sysadmins
        AND s.sysadmin = 1
GO