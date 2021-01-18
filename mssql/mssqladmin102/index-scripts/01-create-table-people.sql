USE SQL2
GO

CREATE TABLE People
(
    PeopleID int Identity (1,1),
    Fname varchar(20),
    Lname varchar(20),
    Address1 varchar(100),
    City varchar(50),
    State varchar(50),
    Zip varchar(10),
    Country varchar(50),
    Phone varchar(20)
)

BACKUP DATABASE [SQL2]
TO DISK = N'C:\Program files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Backup\SQL2.bak'
WITH NOFORMAT,
NOINIT,
NAME = N'SQL2-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO