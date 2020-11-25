--Drop database BackupDatabase

--Create a test database

Use master
go

Create database BackupDatabase
go


use BackupDatabase 
go

--Create table

Create table Products
(ProductID int IDENTITY (1,1) Primary Key,
ProductName varchar (100),
Brand varchar (100))
go

--Insert data into table

insert into Products values ('motor','chevy')
insert into Products values ('Hat','Nike')
insert into Products values ('Shoe','Payless')
insert into Products values ('Phone','Apple')
insert into Products values ('Book','Green')
insert into Products values ('Cup','Large')

--View data

select * from Products

--Take full database backup of six rows using GUI

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--Insert data into table AFTER a full database backup, but before a transactional log backup

Insert into Products values ('Doll','Toy_R_us')

--View data

select * from Products

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)
--Using a GUI (number 1)


--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--BackupType
--1 = Full
--2 = T Log
--5 = Differential

 --Another insert

Insert into Products values ('House','Remax')

select * from Products

--another transaction log backup

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)
--Using a GUI (number 2)

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--At this point, we have 1 full database backup with data from 1 to 6 rows
--1 (first) transactional log backup of row 7
--2 (second) transactional log backup of row 8

--To restore the database if a disaster occured, we will need ALL the full, and 2 transactional logs to recover all the data from 1 through 8 rows

--Lets delete the database and restore the using GUI