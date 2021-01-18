USE AdventureWorks2014
GO

-- Stored Procedure to find all created indexes.
sp_helpindex '[HumanResources].[Department]'

USE [SQL2]
GO

CREATE NONCLUSTERED INDEX [NC_Idx_People_lname_fname]
ON [dbo].[People] (lname ASC, fname ASC)

sp_helpindex People