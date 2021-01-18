/*
Note: Table people in db SQL2 contains 100 million rows.
*/

-- Using the WHERE clause without an index (1 min 10 sec)
-- Display estimated execution plan (Shows that a table scan will be executed and missing non clustered index is suggested on lname and other columns)
-- The display estimated execution plan does not execute the query, but shows the plan if executed

USE [SQL2]
GO

SELECT PeopleID, Fname, Lname, Address1, City, State, Zip, country, Phone
FROM [dbo].[People]
WHERE Lname = 'Spence'
GO

-- Using the WHERE clause without a non clustered index on Lname (1 min 10 sec)
-- Crete the suggested non clustered index

CREATE NONCLUSTERED INDEX [Idx_Suggested_Index]
ON [dbo].[People].[Lname]
GO

SELECT PeopleID, Fname, Lname, Address1, City, State, Zip, country, Phone
FROM [dbo].[People]
WHERE Lname = 'Zuniga'
GO
-- Takes 2 min 15 sec


SELECT PeopleID, Fname, Lname
FROM [dbo].[People]
WHERE Lname = 'Spence'
GO
-- Takes 2 sec