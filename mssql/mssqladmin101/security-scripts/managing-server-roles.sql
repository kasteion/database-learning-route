USE [AdventureWorks2012]
		GO

		CREATE ROLE [HR_Tables]
GO

GRANT SELECT ON [HumanResources].[Employee]
TO [HR_Tables]
GO

GRANT SELECT ON [HumanResources].[Department]
TO [HR_Tables]
GO

ALTER ROLE [HR_Tables]
ADD MEMBER [Peter]
GO

ALTER ROLE [HR_Tables]
ADD MEMBER [Robert]
GO

	USE [master]
		GO

		CREATE SERVER ROLE [Junior DBA Manage DB]
		GO

		GRANT CREATE ANY DATABASE
		TO [Junior DBA Manage DB]
		GO

		GRANT VIEW ANY DATABASE
		TO [Junior DBA Manage DB]
GO

ALTER SERVER ROLE [Junior DBA Manage DB]
ADD MEMBER [Peter]

ALTER SERVER ROLE [Junior DBA Manage DB]
ADD MEMBER [Robert]

	
USE [AdventureWorks2012]
GO

GRANT SELECT ON [HumanResources].[Employee] TO [Peter],[Robert] AS [dbo]
GO

REVOKE SELECT ON [HumanResources].[Employee] to [Peter], [Robert] AS [dbo]
GO

------------------------------------------------------------------------------------------------------------
		ALTER ROLE [db_datareader] ADD MEMBER [Peter]
		GO

		DENY SELECT ON [Production].[Product] TO [Peter]
		GO

		REVOKE SELECT ON [Production].[Product] TO [Peter]

		ALTER ROLE [db_datareader] DROP MEMBER [Peter]
------------------------------------------------------------------------------------------------------------

CREATE SERVER ROLE [ServerRole-20190520]
GO

ALTER SERVER ROLE [ServerRole-20190520] ADD MEMBER [Peter]
GO

DENY VIEW ANY DATABASE TO [ServerRole-20190520]
GO

USE [AdventureWorks2012]
GO

DENY CONNECT TO [Peter], [Robert]
GO

ALTER SERVER ROLE [ServerRole-20190520] DROP MEMBER [Peter]
GO

