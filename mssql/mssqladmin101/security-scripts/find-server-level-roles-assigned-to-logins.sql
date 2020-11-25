----Script to find server level roles assigned to Server level logins \ roles

--SELECT a.name as Name,a.type_desc AS LoginType, a.default_database_name AS DefaultDBName,
--ISNULL(SUSER_NAME(b.role_principal_id),'public') AS AssociatedServerRole
--FROM sys.server_principals a LEFT JOIN sys.server_role_members b ON a.principal_id=b.member_principal_id
--WHERE a.is_fixed_role <> 1 AND a.name NOT LIKE '##%'AND a.name <> 'public' ORDER BY Name, LoginType


----Script to find Server level permissions assigned to Server level logins \ roles
--SELECT a.name AS Name, a.type_desc AS LoginType,b.class_desc AS ClassDesc
--,b.permission_name AS ServerLevelPermission,b.state_desc AS PermissionState
--FROM sys.server_principals a JOIN sys.server_permissions b
--ON a.principal_id = b.grantee_principal_id WHERE a.is_fixed_role <> 1
--AND a.name NOT LIKE '##%' AND a.name NOT LIKE 'NT%' AND a.name <> 'public'  ORDER BY Name

----Script to find all user database level roles assigned to database users \ roles
--DECLARE @DBuser_sql VARCHAR(4000)
--DECLARE @DBuser_table TABLE (DBName VARCHAR(200), UserName VARCHAR(250), LoginType VARCHAR(500), Authentication_type VARCHAR(250),AssociatedRole VARCHAR(200))
--SET @DBuser_sql='SELECT ''?'' AS DBName,a.name AS Name,a.type_desc AS LoginType, CASE a.authentication_type
--WHEN 0 THEN ''No Authencication''
--WHEN 1 THEN ''Uncontained User - Instance Level''
--WHEN 2 THEN ''Contained User - Database Level''
--WHEN 3 THEN ''Windows Login User'' END As AuthenticationType,
--USER_NAME(b.role_principal_id) AS AssociatedRole FROM ?.sys.database_principals a
--RIGHT OUTER JOIN ?.sys.database_role_members b ON a.principal_id=b.member_principal_id
--WHERE a.sid IS NOT NULL AND a.type NOT IN (''C'')
--AND a.is_fixed_role <> 1 AND a.name NOT LIKE ''##%'' AND a.name NOT LIKE ''NT%''
--AND a.name NOT IN (''public'',''dbo'',''guest'')
--AND ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'') ORDER BY DBName'
--INSERT @DBuser_table
--EXEC sp_MSforeachdb @command1=@dbuser_sql
--SELECT * FROM @DBuser_table ORDER BY DBName


----
--DECLARE @Obj_sql VARCHAR(2000)
--DECLARE @Obj_table TABLE (DBName VARCHAR(200), UserName VARCHAR(250),Authentication_Type VARCHAR(250), Permission VARCHAR(500), PermissionState VARCHAR(200))
--SET @Obj_sql='SELECT ''?'' AS DBName,a.name AS UserName,CASE a.authentication_type
--WHEN 0 THEN ''No Authencication''
--WHEN 1 THEN ''Uncontained User - Instance Level''
--WHEN 2 THEN ''Contained User - Database Level''
--WHEN 3 THEN ''Windows Login User'' END As AuthenticationType,
--b.permission_name AS Permission,b.state_desc AS PermissionState
--FROM ?.sys.database_principals a join
--?.sys.database_permissions  b on a.principal_id=b.grantee_principal_id
--WHERE a.name not in (''public'',''guest'',''dbo'') AND b.class <> 1
--AND a.name NOT LIKE ''NT%'' AND ''?'' NOT IN (''master'',''model'',''msdb'',''tempdb'')'
--INSERT @Obj_table
--EXEC sp_msforeachdb @command1=@Obj_sql
--SELECT * FROM @Obj_table ORDER BY DBName



--DECLARE @Obj_sql VARCHAR(2000)
--DECLARE @Obj_table TABLE (DBName VARCHAR(200), UserName VARCHAR(250),Authentication_Type VARCHAR(250), ObjectName VARCHAR(500), Permission VARCHAR(200))
--SET @Obj_sql='SELECT ''?'' AS DBName,U.name as username,  CASE S.authentication_type
--WHEN 0 THEN ''No Authencication''
--WHEN 1 THEN ''Uncontained User - Instance Level''
--WHEN 2 THEN ''Contained User - Database Level''
--WHEN 3 THEN ''Windows Login User'' END AS AuthenticationType,
--O.name as object,  permission_name AS permission from ?.sys.database_permissions
--JOIN ?.sys.sysusers U ON grantee_principal_id = uid
--JOIN ?.sys.database_principals S ON s.principal_id=U.uid
--JOIN ?.sys.sysobjects O ON major_id = id
--WHERE ''?'' NOT IN (''master'',''msdb'',''model'',''tempdb'')'
--INSERT @Obj_table
--EXEC sp_msforeachdb @command1=@Obj_sql
--SELECT * FROM @Obj_table ORDER BY DBName



---------------------------------------------


----Run the below on each database for database-level security.
 
--SELECT DB_NAME() as Database_Name
 
----Database Level Roles
--SELECT DISTINCT
--     QUOTENAME(r.name) as database_role_name, r.type_desc, QUOTENAME(d.name) as principal_name, d.type_desc
--,    TSQL = 'EXEC sp_addrolemember @membername = N''' + d.name COLLATE DATABASE_DEFAULT + ''', @rolename = N''' + r.name + ''''
--FROM sys.database_role_members AS rm
--inner join sys.database_principals r on rm.role_principal_id = r.principal_id
--inner join sys.database_principals d on rm.member_principal_id = d.principal_id
--where d.name not in ('dbo', 'sa', 'public')
 
----Database Level Security
--SELECT     rm.state_desc
--     ,   rm.permission_name
--    ,   QUOTENAME(u.name) COLLATE database_default
--    ,   u.TYPE_DESC
--     ,   TSQL = rm.state_desc + N' ' + rm.permission_name + N' TO ' + cast(QUOTENAME(u.name COLLATE DATABASE_DEFAULT) as nvarchar(256))   
--FROM sys.database_permissions AS rm
--     INNER JOIN
--     sys.database_principals AS u
--     ON rm.grantee_principal_id = u.principal_id
--WHERE rm.major_id = 0
--and u.name not like '##%'
--and u.name not in ('dbo', 'sa', 'public')
--ORDER BY rm.permission_name ASC, rm.state_desc ASC
 
----Database Level Explicit Permissions
--SELECT     perm.state_desc
--    , perm.permission_name
--    ,   QUOTENAME(USER_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.name)
--       + CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name COLLATE DATABASE_DEFAULT) + ')' END AS [Object]
--     , QUOTENAME(u.name COLLATE database_default) as Usr_Name
--    ,   u.type_Desc
--    , obj.type_desc
--    ,  TSQL = perm.state_desc + N' ' + perm.permission_name
--           + N' ON ' + QUOTENAME(USER_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.name)
--           + N' TO ' + QUOTENAME(u.name COLLATE database_default)
--FROM sys.database_permissions AS perm
--     INNER JOIN
--     sys.objects AS obj
--     ON perm.major_id = obj.[object_id]
--     INNER JOIN
--     sys.database_principals AS u
--     ON perm.grantee_principal_id = u.principal_id
--     LEFT JOIN
--     sys.columns AS cl
--     ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
--where
--     obj.name not like 'dt%'
--and obj.is_ms_shipped = 0
--and u.name not in ('dbo', 'sa', 'public')
--ORDER BY perm.permission_name ASC, perm.state_desc ASC


--------------------------------------------------

--/*
--Script DB Level Permissions v2.1
--Source: http://www.sqlservercentral.com/scripts/Security/71562/
--*/

--DECLARE 
--    @sql VARCHAR(2048)
--    ,@sort INT 

--DECLARE tmp CURSOR FOR


--/*********************************************/
--/*********   DB CONTEXT STATEMENT    *********/
--/*********************************************/
--SELECT '-- [-- DB CONTEXT --] --' AS [-- SQL STATEMENTS --],
--        1 AS [-- RESULT ORDER HOLDER --]
--UNION
--SELECT  'USE' + SPACE(1) + QUOTENAME(DB_NAME()) AS [-- SQL STATEMENTS --],
--        1 AS [-- RESULT ORDER HOLDER --]

--UNION

--SELECT '' AS [-- SQL STATEMENTS --],
--        2 AS [-- RESULT ORDER HOLDER --]

--UNION

--/*********************************************/
--/*********     DB USER CREATION      *********/
--/*********************************************/

--SELECT '-- [-- DB USERS --] --' AS [-- SQL STATEMENTS --],
--        3 AS [-- RESULT ORDER HOLDER --]
--UNION
--SELECT  'IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] = ' + SPACE(1) + '''' + [name] + '''' + ') BEGIN CREATE USER ' + SPACE(1) + QUOTENAME([name]) + ' FOR LOGIN ' + QUOTENAME([name]) + ' WITH DEFAULT_SCHEMA = ' + QUOTENAME([default_schema_name]) + SPACE(1) + 'END; ' AS [-- SQL STATEMENTS --],
--        4 AS [-- RESULT ORDER HOLDER --]
--FROM    sys.database_principals AS rm
--WHERE [type] IN ('U', 'S', 'G') -- windows users, sql users, windows groups

--UNION

--/*********************************************/
--/*********    DB ROLE PERMISSIONS    *********/
--/*********************************************/
--SELECT '-- [-- DB ROLES --] --' AS [-- SQL STATEMENTS --],
--        5 AS [-- RESULT ORDER HOLDER --]
--UNION
--SELECT  'EXEC sp_addrolemember @rolename ='
--    + SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername =' + SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '''') AS [-- SQL STATEMENTS --],
--        6 AS [-- RESULT ORDER HOLDER --]
--FROM    sys.database_role_members AS rm
--WHERE   USER_NAME(rm.member_principal_id) IN (  
--                                                --get user names on the database
--                                                SELECT [name]
--                                                FROM sys.database_principals
--                                                WHERE [principal_id] > 4 -- 0 to 4 are system users/schemas
--                                                and [type] IN ('G', 'S', 'U') -- S = SQL user, U = Windows user, G = Windows group
--                                              )
----ORDER BY rm.role_principal_id ASC


--UNION

--SELECT '' AS [-- SQL STATEMENTS --],
--        7 AS [-- RESULT ORDER HOLDER --]

--UNION

--/*********************************************/
--/*********  OBJECT LEVEL PERMISSIONS *********/
--/*********************************************/
--SELECT '-- [-- OBJECT LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --],
--        8 AS [-- RESULT ORDER HOLDER --]
--UNION
--SELECT  CASE 
--            WHEN perm.state <> 'W' THEN perm.state_desc 
--            ELSE 'GRANT'
--        END
--        + SPACE(1) + perm.permission_name + SPACE(1) + 'ON ' + QUOTENAME(SCHEMA_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.name) --select, execute, etc on specific objects
--        + CASE
--                WHEN cl.column_id IS NULL THEN SPACE(0)
--                ELSE '(' + QUOTENAME(cl.name) + ')'
--          END
--        + SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default
--        + CASE 
--                WHEN perm.state <> 'W' THEN SPACE(0)
--                ELSE SPACE(1) + 'WITH GRANT OPTION'
--          END
--            AS [-- SQL STATEMENTS --],
--        9 AS [-- RESULT ORDER HOLDER --]
--FROM    
--    sys.database_permissions AS perm
--        INNER JOIN
--    sys.objects AS obj
--            ON perm.major_id = obj.[object_id]
--        INNER JOIN
--    sys.database_principals AS usr
--            ON perm.grantee_principal_id = usr.principal_id
--        LEFT JOIN
--    sys.columns AS cl
--            ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
----WHERE usr.name = @OldUser
----ORDER BY perm.permission_name ASC, perm.state_desc ASC



--UNION

--SELECT '' AS [-- SQL STATEMENTS --],
--    10 AS [-- RESULT ORDER HOLDER --]

--UNION

--/*********************************************/
--/*********    DB LEVEL PERMISSIONS   *********/
--/*********************************************/
--SELECT '-- [--DB LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --],
--        11 AS [-- RESULT ORDER HOLDER --]
--UNION
--SELECT  CASE 
--            WHEN perm.state <> 'W' THEN perm.state_desc --W=Grant With Grant Option
--            ELSE 'GRANT'
--        END
--    + SPACE(1) + perm.permission_name --CONNECT, etc
--    + SPACE(1) + 'TO' + SPACE(1) + '[' + USER_NAME(usr.principal_id) + ']' COLLATE database_default --TO <user name>
--    + CASE 
--            WHEN perm.state <> 'W' THEN SPACE(0) 
--            ELSE SPACE(1) + 'WITH GRANT OPTION' 
--      END
--        AS [-- SQL STATEMENTS --],
--        12 AS [-- RESULT ORDER HOLDER --]
--FROM    sys.database_permissions AS perm
--    INNER JOIN
--    sys.database_principals AS usr
--    ON perm.grantee_principal_id = usr.principal_id
----WHERE usr.name = @OldUser

--WHERE   [perm].[major_id] = 0
--    AND [usr].[principal_id] > 4 -- 0 to 4 are system users/schemas
--    AND [usr].[type] IN ('G', 'S', 'U') -- S = SQL user, U = Windows user, G = Windows group

--UNION

--SELECT '' AS [-- SQL STATEMENTS --],
--        13 AS [-- RESULT ORDER HOLDER --]

--UNION 

--SELECT '-- [--DB LEVEL SCHEMA PERMISSIONS --] --' AS [-- SQL STATEMENTS --],
--        14 AS [-- RESULT ORDER HOLDER --]
--UNION
--SELECT  CASE
--            WHEN perm.state <> 'W' THEN perm.state_desc --W=Grant With Grant Option
--            ELSE 'GRANT'
--            END
--                + SPACE(1) + perm.permission_name --CONNECT, etc
--                + SPACE(1) + 'ON' + SPACE(1) + class_desc + '::' COLLATE database_default --TO <user name>
--                + QUOTENAME(SCHEMA_NAME(major_id))
--                + SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(USER_NAME(grantee_principal_id)) COLLATE database_default
--                + CASE
--                    WHEN perm.state <> 'W' THEN SPACE(0)
--                    ELSE SPACE(1) + 'WITH GRANT OPTION'
--                    END
--            AS [-- SQL STATEMENTS --],
--        15 AS [-- RESULT ORDER HOLDER --]
--from sys.database_permissions AS perm
--    inner join sys.schemas s
--        on perm.major_id = s.schema_id
----    inner join sys.database_principals dbprin
----        on perm.grantee_principal_id = dbprin.principal_id
----WHERE class = 3 --class 3 = schema


----ORDER BY [-- RESULT ORDER HOLDER --]


----OPEN tmp
----FETCH NEXT FROM tmp INTO @sql, @sort
----WHILE @@FETCH_STATUS = 0
----BEGIN
----        PRINT @sql
----        FETCH NEXT FROM tmp INTO @sql, @sort    
----END

----CLOSE tmp
----DEALLOCATE tmp 


----------------------------

--SQL DBA often needs to script SQL Logins,Server roles,database users and Roles. Although its easy to script login,roles and users with SSMS, associating login to server Roles and database users to db roles is not straight forward using Script Wizard. We can easily overcome this using below TSQL scripts.


--/*ASSIGN SERVER ROLES TO LOGIN*/
--SELECT
--'EXEC sp_addsrvrolemember '
--+ SPACE(1) + QUOTENAME(rm.name, '''')+','
--+ SPACE(1) + QUOTENAME(rm1.name, '''') AS '--Role Memberships'
--from sys.server_role_members a
--INNER JOIN
--sys.server_principals rm ON a.member_principal_id = rm.principal_id
--INNER JOIN
--sys.server_principals rm1 ON a.role_principal_id = rm1.principal_id
-------------------------------------------------------------
--/*CREATE DATABASE USERS*/
--SELECT 'CREATE USER [' + a.name + '] for login [' + b.name + ']'  from sys.database_principals a
--INNER JOIN sys.server_principals b ON a.sid = b.sid
--where a.name <> 'dbo'
-------------------------------------------------------------
--/*CREATE DATABASE ROLES*/
--SELECT 'CREATE ROLE [' + a.name + '] AUTHORIZATION [' + b.name + ']' from sys.database_principals a
--INNER JOIN sys.database_principals b ON a.owning_principal_id = b.principal_id
--where a.type = 'R' and a.is_fixed_role <> 1
--GO
--------------------------------------------------------------
--/*ASSIGN ROLES TO USER*/
--SELECT --rm.role_principal_id,
--'EXEC sp_addrolemember @rolename ='
--+ SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''')
--+ ', @membername =' + SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '''') AS '--Role Memberships'
--FROM sys.database_role_members AS rm
--ORDER BY rm.role_principal_id
--GO
--------------------------------------------------------------
--/*SELECT OBJECT LEVEL PERMISSION*/
--SELECT
--CASE WHEN perm.state != 'W' THEN perm.state_desc ELSE 'GRANT' END + SPACE(1) +
--perm.permission_name + SPACE(1) + 'ON '+ QUOTENAME(Schema_NAME(obj.schema_id)) + '.'
--+ QUOTENAME(obj.name) collate Latin1_General_CI_AS_KS_WS
--+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name) + ')' END
--+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(usr.name)
--+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Object Level Permissions'
--FROM sys.database_permissions AS perm
--INNER JOIN
--sys.objects AS obj
--ON perm.major_id = obj.[object_id]
--INNER JOIN
--sys.database_principals AS usr
--ON perm.grantee_principal_id = usr.principal_id
--LEFT JOIN
--sys.columns AS cl
--ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
--ORDER BY usr.name
--------------------------------------------------------------
--/*SELECT OBJECT LEVEL PERMISSION FOR A OBJECT*/
--SELECT
--CASE WHEN perm.state != 'W' THEN perm.state_desc ELSE 'GRANT' END + SPACE(1) +
--perm.permission_name + SPACE(1) + 'ON '+ QUOTENAME(Schema_NAME(obj.schema_id)) + '.'
--+ QUOTENAME(obj.name) collate Latin1_General_CI_AS_KS_WS
--+ CASE WHEN cl.column_id IS NULL THEN SPACE(0) ELSE '(' + QUOTENAME(cl.name) + ')' END
--+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(usr.name)
--+ CASE WHEN perm.state <> 'W' THEN SPACE(0) ELSE SPACE(1) + 'WITH GRANT OPTION' END AS '--Object Level Permissions'
--FROM sys.database_permissions AS perm
--INNER JOIN
--sys.objects AS obj
--ON perm.major_id = obj.[object_id]
--INNER JOIN
--sys.database_principals AS usr
--ON perm.grantee_principal_id = usr.principal_id
--LEFT JOIN
--sys.columns AS cl
--ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id
--Where obj.name = 'ULTIMATES_CURRENT'
--ORDER BY usr.name

---------------------------------------


--SQL Server – Get all Login Accounts Using T-SQL Query – SQL Logins, Windows Logins, Windows Groups

--August 6, 2013 by Suresh Raavi

--Earlier today I was required to pull the list of all SQL Login Accounts, Windows Login Accounts and Windows Group Login Accounts (basically all the Logins along with the Account Type of the Login) on one of the SQL Server instance where there are close to a hundred Login Accounts existing.

--Doing it from SSMS GUI will take forever. So, I wrote a simple T-SQL script using which I was able to pull out all that information in less than a second!

--Get the list of all Login Accounts in a SQL Server

SELECT name AS Login_Name, type_desc AS Account_Type
FROM sys.server_principals 
WHERE TYPE IN ('U', 'S', 'G')
and name not like '%##%'
ORDER BY name, type_desc

--Get the list of all SQL Login Accounts only

SELECT name
FROM sys.server_principals 
WHERE TYPE = 'S'
and name not like '%##%'

--Get the list of all Windows Login Accounts only

SELECT name
FROM sys.server_principals 
WHERE TYPE = 'U'

--Get the list of all Windows Group Login Accounts only

SELECT name
FROM sys.server_principals 
WHERE TYPE = 'G'