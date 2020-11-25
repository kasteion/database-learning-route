--Create a SQL Login not using Windows User

USE [master]
GO

CREATE LOGIN [Mary] 
WITH PASSWORD=N'password123' --<< password does not meet complexity (use upper 'P')
MUST_CHANGE, DEFAULT_DATABASE=[master], 
CHECK_EXPIRATION=ON, 
CHECK_POLICY=ON
GO

USE [AdventureWorks2012]
GO

CREATE USER [Mary] FOR LOGIN [Mary] --<< Create a SQL Login
GO

USE [AdventureWorks2012]
GO

ALTER ROLE [db_datareader] --<< Add SQL Login to database Role (db_datareader)
ADD MEMBER [Mary]
GO
