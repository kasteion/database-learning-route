USE [SQL2]
GO

-- Example: Running a query without an index looking for the last name 'Franklyn600'
-- as there is no index on the lname, the query will have to start from the first row and sequentially go through
-- all the 50 millions rows until it finds the lname 'Franklin600'(This is called a table scan and has very poor performance)

Select * FROM [dbo].[People] Where lname = 'Franklin600'
GO

-- Takes 35 seconds

-- Create an index on lname (to create an index on lname column, the data has to be sorted and has pointers to the actual data in the table)
-- the creation of an index can take a long time because it is 'copying' the column lname separately with pointers to data
--  Any tyme you update the table people with an insert, update or delete, the index on that column has to be updated also.

CREATE NONCLUSTERED INDEX [NC_Idx_People_lname]
ON [dbo].[People] ([lname] ASC)

-- Takes 2:45 mins

-- Run select statement after the index creating
Select * from [dbo].[People] where lname = 'Franklin600';
GO
Select * from [dbo].[People] where lname = 'Everett652';
GO
-- Takes less than a second