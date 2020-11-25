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
insert into Products values ('Cup','Large') -- 6 rows (full)

--View data

select * from Products

--********Take full database backup of six rows using GUI******

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--Insert data into table AFTER a full database backup, but before a transactional log backup

Insert into Products values ('Doll','Toy_R_us') --7 rows (tlog 1)

--View data

select * from Products

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)
--******Using a GUI (number 1)*******


--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

--BackupType
--1 = Full
--2 = T Log
--5 = Differential

 --Another insert

Insert into Products values ('House','Remax') --8 rows (first diff)

select * from Products

--*****take first differnetial backup using GUI***** 

RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

Insert into Products values ('Desk','Ikea') --9 rows (tlog 2)

--another transaction log backup

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)
--Using a GUI (number 2)

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'

select * from Products

Insert into Products values ('Desk','Ikea') --10 rows (second diff)

--*****take second differnetial backup using GUI*****

--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'


Insert into Products values ('Book','BAN') --11 rows (tlog 3)

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)
--Using a GUI (number 3)

Insert into Products values ('Book','BAN') --12 rows (tlog 4)

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)
--Using a GUI (number 4)


Insert into Products values ('Chips','Lays') --13 rows (tlog 5)

--Taking a transactional log backup (this can only be taken if the database recovery model is in Full mode, and a full database backup had been executed)
--Using a GUI (number 5)


--At this point, we have 1 full database backup with data from 1 to 6 rows
--1 (first) transactional log backup of row 7
--1 (first) differential backups of row 8
--2 (second) transactional log backup of row 9
--2 (second) differential log backup of row 10
--3 (third) transactional log backup of row 11
--4 (fourth) transactional log backup of row 12
--5 (fifth) transactional log backup of row 13

--To restore the database if a disaster occured AND we are using differential backups, we need only the LAST differential plus
--all the following transactional logs to restore the database! 
--Lets delete the database and restore the using GUI


--Look insde the .bak file
RESTORE HEADERONLY FROM DISK = N'c:\fullbackups\BackupDatabase.bak'
