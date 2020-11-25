# WHAT IS A WINDOWS DOMAIN

A Windows domain is a computer network in which all user accounts, computers, printers and other security principals, are registered with a central database (called Active Directory Service) located on a domain controller.

A stand alone server is not part of a domain.

## PREPARING THE ENVIRONMENT

- Download Virtual Box and Install
- Download Windows server iso
- Create virtual machine for domain controller and install windows server OS.
- Promote Windows Server OS to Domain Controller (DC)
    - From Server Manager, add roles and choose the Domain Controller Roles. The role to add is Active Directory Domain Services. After installing the rol we can promote the server to Domain Controler. Add a new forest...
- Create service accounts for SQL Server on DC
- Create another virtual machine and install Windows Server OS
- Join Machine to Domain
- Install SQL Server, configuring SQL Server using multiple drives and service accounts.

## DRIVES FOR SQL SERVER VIRTUAL MACHINE

- C Drive: OS and DBMS
- D Drive: System Files
- E Drive: MDF Files
- F Drive: LDF Files
- G Drive: tempdb data files
- H Drive: tempdb log files

## SQL Server Files

- MDF (Contains data)
- LDF (Contains logs)
- NDF (More data and indexes)
- Temdb data file
- Tempdb log file

## Service Accounts

SQL Server runs as a service; in background. Service Accounts have to be created for each service (i.e. SQL, SSIS, SSRS).

In the domain controller there should be an OA named SQL Service Accounts, then inside this OA create four users: SSAS, SSIS, SSMS, SSRS (For Analysis Services, Information Services, SQL and Reporting Service).

# SERVICE PACKS

Service packs that are released by Microsoft contain important fiexs for the product and are vigorously tested before being released to the public; so they're pretty important to install. But, as always, it is recommended to apply them in a test server and test them thoroughly before applying to the production server.

Determine the version and service pack of SQL Server running:

> select @@version

All SQL server service packs are cumulative, meaning that each new service contains all the fixes that are included with previous service packs and any new file.

## SQL SERVER SYSTEM DATABASES

Each time you install any SQL Server Editions on a serve; there are four primary system databases, each of which must be present for the server to perate effectively.

**Master**
- file locations of the user databases
- login accounts
- server configuration settings
- linked servers information
- startup stored procedures

**Model**
- A template database that is copied into a new database
- Options set in model will be applied to new databases
- Used to create tempdb every time the server starts

**Msdb**
- Support SQL Server Agent
- SQL Server Management Studio
- Database Mail
- Service Broker
- History and metadata information is available in msdb
- Backup and restore history for the databases
- History for SQL agent jobs

**Tempdb**
- The tempdb is a shared resource used by SQL Server all users.
- Tempdb is used for temporary objects, worktables, online index operations, cursors, table variables, and the snapshot isolation version store, among othe things.
- It is recreated every time that the server is restarted
- As tempdb is non permanent storage, backups and restores are not allowed for this database.

**Reporting Services Databases**
- ReportServer - Available if you have installed Reporting Services
- ReportServerTemp - Available if you have installed Report Services

**Replication System Database**
- Distribution - Available when you configure Replication.

**Resource Database**
- Read-Only hidden database that contains all the system information
- Can't back up the Resource database
- Musto copy paste the file
- C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn
