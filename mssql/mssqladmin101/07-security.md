# UNDERSTANDING WINDOWS AND SQL SECURITY USERS

- Windows username: Account that accesses a Windows Domain.
- Windows Groups: Account that accesses a Windows Domain vía a group.
- SQL Login: Account that accesses SQL Server
- SQL User: Account that accesses SQL Server Databases
- SQL Roles: Account that accesses SQL Server Roles
- What is Windows username and mapping? - Refers to associating Windows users to SQL Logins.

# CHOOSING AUTHENTICATION FOR SQL SERVER

During the installation of SQL Server, an option for security is asked for, that is, the type of authentication you want SQL to apply; either Windows Authentication mode and mixed mode.

If you chose Windows Authentication mode, the Windows Authentication will disable SQL Server Authentication by default.

If you chose mixed mode (Windows Authetnication and SQL Server Authentication) then you must provde and then confirm a strong password for the built-in SQL Server system administrator account named sa.

Because the sa account is well known and often targeted by malicious users, do not enable the sa account unless your application requires it and even then be very carful in giving it out. Create anothe account and give it sysadmin rights if needed. Ideally, you should not activate the sa account and if you do. rename the account.

## VERIFYING CONNECTION VIA WINDOWS AUTHENTICATION

When a user connects through a Windows user account, SQL Server validates the account name and password using the Windows principal token in the operating system. As Windows authentication has built in security protocols, password policy enforcement, complexity for strong passwords, support for account lockdown, and supports password expiration it's recomended over SQL Authentication.

## VERIFYING CONNECTION VIA SQL AUTHENTICATION

When using SQL Server Authentication, logins are created in SQL Server that is not based on Windows user accounts. Both the user name and the password are created using SQL Server and stored in SQL Server.

## SOME REASONS TO USE SQL SERVER AUTHENTICATION

- Support older applications.
- Third parties applications that require SQL Server Authentication
- Supports mixed operating systems, where all users are not autheticated by a Windows domain.
- Support Web-based applications where users create their own identities
- Allows software developers to distribute their applications by using a complex permission hierarchy

# CREATING SQL ROLES

What are SQL Roles - Predefined collection of objects and permissions.

Roles allow the dba to manage permissions more efficiently.

We first create roles and then assign permissions to roles, and then add logins to the roles.

## SQL SERVER SUPPORTS FOUR TYPES OF ROLES

- Fixed database roles - Thes roles already have predefined set of permissions.
- User-defined database roles - These roles have their set of permissions defined by the sa.
- Fixed server roles - These roles already have predefined set of permissions.
- User defined server roles - These roles have their set of permissions defined by the sa.

The following shows the fixed database-levl roles and their capabilities. These roles exist in all databases.

## DATABASE LEVEL ROLE

**db_owner**

Members of the db_owner fixed database role can perform all configuration and maintenance activities on the database, and can also drop the database.

**db_securityadmin**

Members of the db_securityadmin fixed database role can modify role membership and manage permissions (be careful)

**db_accessadmin**

Members of the db_accessadmin fixed database role can add or remove access to the database for Windows logins, Windows groups, and SQL Server logins.

**db_backupoperator**

Members of the db_backupoperator fixed database role can back up the database.

**db_ddladmin**

Members of the db_ddladmin fixed database role can run any Data Definition Language (DDL) command in a database.

**db_datawriter**

Members of the db_datawriter fixed database role can add, delete, or change data in all user tables.

**db_datareader**

Members of the db_datareader fixed database role can read all data from all user tables.

**db_denydatawriter**

Members of the db_denydatawriter fixed database role cannot add, modify, or delete any data in the user tables within a database.

**db_denydatareader**

Members of the db_denydatareader fixed database role cannot read any data in the user tables within a database.

## SQL SERVER ROLES

The Server Roles page lists all possible roles that can be assigned to the new login.

**bulkadmin**

Members of the bulkadmin fixed server role can run the BULK INSERT statement.

**dbcreator**

Members of the dbcreator fixed server role can create, alter, drop, and restore any database.

**diskadmin**

Members of the diskadmin fixed server role can manage disk files.

**processadmin**

Members of the processadmin fixed server role can terminate processes running in an instance of the Database Engine.

**public**

All SQL Server users, groups, and roles belong to the public fixed server role by default.

**securityadmin**

Members of the securityadmin fixed server role manage logins and their properties. They can GRANT, DENY, and REVOKE server-level permissions. They can also GRANT, DENY, and REVOKE database-level permissions. Additionally, they can reset passwords for SQL Server Logins.

**serveradmin**

Members of the serveradmin fixed server role can change server-wide configuration options and shut down the server.

**setupadmin**

Members of the setupadmin fixed server role can add and remove linked servers, and they can execute some system stored procedures.

**sysadmin**

God like powers - can do anything and everything

Members of the sysadmin fixed server role can perform any activity in the Database Engine.

# WHAT ARE GRANT, DENY, AND REVOKE PERMISSIONS

## GRANT

This allows the principal to perform an action.

## DENY

This Denies permission to a login (principal)

## REVOKE

These removes the grant or deny permission to the securable

**Notes**

A deny will override a grant. This means that if a user is denied permission they cannot inherit a grant from another source.

# BEST PRACTICE TO SECURE THE SQL SERVER

- Start with the physical server room where the Servers are kept.
- Insure that only selected IT staff has access (Networks Admins, System Admins and SQL DBAs)
- Keep the backups not only on site, but keep a copy of backups off site
- Install all service packs and critical fixes for Windows Operating System and SQL Server Service Packs (Test on test server first before applying to production)
- Disable the default admin the BUILTIN\Administrators group from the SQL Server
- Use Windows Authentication mode as opposed to mixed mode
- Use service accounts for applications and create a different service account for each SQL Service.
- Create service accounts with the least privileges
- Document all user permissions with the script and keep track of which user has what permissions
- Disable all features via the SQL Server Configuration Manager that are not in use
- Install only required components when installing SQL Server (don't install ssrs, ssis, ssas)
- Disable the sa accoutn and rename it
- Remove the BUILTIN\Administrators Windows Group from SQL
- Use SQL Server Roles to limit logins accessing databases
- Use permission to give only that is neede to the SQL Login or User
- Hide all databases from logins
- Be proactive in securing the SQL SErver and databases
