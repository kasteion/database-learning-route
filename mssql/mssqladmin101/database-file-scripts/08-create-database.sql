--create database either by GUI or script it out

--Create a database with proper configuration taking in the following consideration:

--pre size the data file and auto growth property of the data file
--pre size the log file and auto growth property of the log file
--have each data and transaction log file on its own physical drive
--sizing based on the activity that your environment uses
--base your size roughly on two or three years of growth patterns

--NOTE: CHANGED THE DEFAULT KB TO MG!

USE master
GO

CREATE DATABASE [Production2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Production2', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Production2.mdf' , --<< this must be in its own physical drive
SIZE = 5MB , --<< pre size the data file 5000 mb
FILEGROWTH = 1MB )  --<< pre size the log file 100 mb

 LOG ON 
( NAME = N'Production2_log', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\Production2_log.ldf' , --<< this must be in its own physical drive
SIZE = 1MB , --<< pre size size of transaction log file 100 mb
FILEGROWTH = 1MB ) --<< pre size size auto growth to increase in increments of 5 mb
GO


sp_helpdb [Production]

-- 1 minute and 10 seconds to create a database for database file size 5 gigs!

--size the physical DRIVE size of both the data and the transaction log file based on activity and workload
--as both the data and log files are on seperate physical hard drives, if possible, allocated the data file and log file to the amount of physical drive!
--we have set the auto growth to increase by 50 mg for the transaction log, but what if a transaction needs more than 50 mg of space, won't that cause
--the auto growth to kick in?
--and if another transaction needs more than 50mg oF space, won't the transaction log get full and stop working?
--YES
--but you must take transaction log backups to truncate the transaction log file so that it does not consume the physical drive!!!