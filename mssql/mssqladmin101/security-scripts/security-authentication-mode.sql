--Change the authentication mode 

USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
N'Software\Microsoft\MSSQLServer\MSSQLServer', 
N'LoginMode', 
REG_DWORD, 1  --<< Windows Authentication Mode
GO

USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
N'Software\Microsoft\MSSQLServer\MSSQLServer', 
N'LoginMode', 
REG_DWORD, 2  --<< SQL Server and  Windows Authentication Mode
GO


--create a login for SQL Server for a single login (Matt)

USE [master]
GO
CREATE LOGIN [Matt] 
WITH PASSWORD=N'password123' 
MUST_CHANGE, 
DEFAULT_DATABASE=[AdventureWorks2012], 
CHECK_EXPIRATION=ON, 
CHECK_POLICY=ON
GO

--Grant Select Only to Matt to view the table

use [AdventureWorks2012]
GO
GRANT SELECT ON [HumanResources].[Department] TO [Matt]
GO


--Granular access to table and columns [DepartmentID],[Name] only

use [AdventureWorks2012]
GO
REVOKE SELECT ON [HumanResources].[Department] TO [Matt] AS [dbo]
GO
use [AdventureWorks2012]
GO
GRANT SELECT ON [HumanResources].[Department] ([DepartmentID]) TO [Matt] AS [dbo]
GO
use [AdventureWorks2012]
GO
GRANT SELECT ON [HumanResources].[Department] ([Name]) TO [Matt] AS [dbo]
GO


--Grant access to all permissions

use [AdventureWorks2012]
GO
GRANT ALTER ON [HumanResources].[Department] TO [Matt]
GO
use [AdventureWorks2012]
GO
GRANT CONTROL ON [HumanResources].[Department] TO [Matt]
GO
use [AdventureWorks2012]
GO
GRANT DELETE ON [HumanResources].[Department] TO [Matt]
GO
use [AdventureWorks2012]
GO
GRANT INSERT ON [HumanResources].[Department] TO [Matt]
GO
use [AdventureWorks2012]
GO
GRANT REFERENCES ON [HumanResources].[Department] TO [Matt]
GO

use [AdventureWorks2012]
GO
GRANT TAKE OWNERSHIP ON [HumanResources].[Department] TO [Matt]
GO
use [AdventureWorks2012]
GO
GRANT UPDATE ON [HumanResources].[Department] TO [Matt]
GO
use [AdventureWorks2012]
GO
GRANT VIEW CHANGE TRACKING ON [HumanResources].[Department] TO [Matt]
GO
use [AdventureWorks2012]
GO
GRANT VIEW DEFINITION ON [HumanResources].[Department] TO [Matt]
GO


--mapp the login Matt to User in the database

USE [AdventureWorks2012]
GO
CREATE USER [Matt] FOR LOGIN [Matt]
GO


--sp_who
--Kill 59