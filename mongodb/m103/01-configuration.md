# THE MONGOD

**What's a daemon?**

A daemon is a program that is meant to be run but not interacted with directly. They usually have a "d" appended to their name.

**What is mongod?**
Mongod is the main daemon process for mongodb. It is the core server of the database, handling connections, requests and consistency of data. Our mongodb deployment might be confomed of more than one server in this case there is one daemon in each server.

When we lauch mongod we are starting the database but we do not interact directly with mongod, we do it with a client application.

Launch mongod:

> mongod

**Default Configuration**
- Port: 27017
- dbpath: /data/db
- bind_ip: localhost (Only local clients can connect)
- auth: disabled (Database client not requires authentication)

Connect to the Mongo shell:

> mongo

To create a new collection:

> db.createCollection("employees")
>
> use admin
>
> db.shutdonwServer()
>
> exit

**Other Database Clients**
- MongoDB Compass
- Drivers (Node, Swift, Java, C/C++, etc.)

## MONGOD OPTIONS

Below are some of the available options for mongod. To see all available options, run: > mongod --help 

**dbpath**

The dbpath is the directory where all the data files for your database are stored. The dbpath also contains journaling logs to provide durability in case of a crash. As we saw before, the path dbpath is /data/db; however, you can specify any directory that exist on your machine. The directory must have read/write permissions since database and journaling files will be written to the directory. To use the dbpath option, include the dbpath flag and specify the name of your directory:

> mongod --dbpath `directory path`

**port**

The port option allows us to specify the port on which mongod will listen for client connections. If we don't specify a port, it will default to 27017. Database clients should specify the same port to connect to mongod. To specify a port run:

> mongod --port `port number`

**auth**

auth enables authentication to control which users can access the database. When auth is specified, all database clients who want to connect to mongod first need to authenticate.

Before ny database users have been configured, a Mongo shell running on localhost will have access to the database. We can configure users and their permission levels using the shell. Once one or more users have been configured, the shell will no longer have default access. To enable authentication, run mongod with the auth option:

> mongod --auth

**bind_ip**

The bind_ip aption allows us to specify which IP addresses mongod should bind to. When mongod binds to an IP address, clients from that address are able to connect to mongod. For instance, if we wanted to allow clients on IP address 123.123.123.123 to access our database, we'd use the following command:

> mongod --bind_ip 123.123.123.123

To bind to multiple addressses and / or hosts, you can specify them in a comma-separated list:

> mongod --bind-ip localhost,123.123.123.123

If using the bind_ip option with external IP addresses, it's recommended to enable auth to ensure that remote clients connecting to mongod have the proper credentials.

## THE MONGOD CONFIGURATION FILE

The mongodb configuration file is a way to organize the options you need to run the mongod or monos process into an easy to parse yaml file. 

**Command Line Options**

1. --dbpath: Basic path configuration options.
2. --logpath: Basic path configuration options.
3. --bind_ip: For accepting connections from other host.
4. --replSet:  
5. --keyFile: 
6. -sslPEMKey: 
7. --sslCAKey: 
8. --sslMode: 
9. --fork: To run as a daemon.

**Configuration File Options**

1. storage.dbPath
2. systemLog.path and systemLog.destination
3. net.bind_ip
4. replication.replSetName
5. security.keyFile
6. net.ssl.sslPEMKey
7. net.ssl.sslCAKey
8. net.sslMode
9. prcessManagement.fork

YAML = YAML Ain't Markup Language

Launch mongod using default configuration:

> mongod

Launch mongod with specified --dbpath and --logpath:

> mongod --dbpath /data/db --logpath /data/log/mongod.log

Launch mongod and fork the process:

> mongod --dbpath /data/db --logpath /data/log/mongod.log --fork

Launch mongod with many configuration options:

> mongod --dbpath /data/db --logpath /data/log/mongod.log --fork --replSet "M103" --keyFile /data/keyfile --bind_ip "127.0.0.1,192.168.103.100" --tlsMode requireTLS --tlsCAFile "/etc/tls/TLSCA.pem" --tlsCertificateKeyFile "/etc/tls/tls.pem"

Note that all "ssl" options have been edited to use "tls" insted. As of MongoDB 4.2 optios using "ssl" have been deprecated.

Example configuration options as above:

        storage:
            dbPath: "/data/db"
        systemLog:
            path: "/data/log/mongod.log"
            destination: "file"
        replication:
            replSetName: M103
        net:
            bindIp : "127.0.0.1,192.168.103.100"
        tls:
            mode: "requireTLS"
            certificateKeyFile: "/etc/tls/tls.pem"
            CAFile: "/etc/tls/TLSCA.pem"
        security:
            keyFile: "/data/keyfile"
        processManagement:
            fork: true

Run mongod using the configuration file:

> mongod --config "/etc/mongod.conf"
>
> mongod -f "/etc/mongod.conf"

For the mongod command line options: https://docs.mongodb.com/manual/reference/program/mongod/
For the mongod configuration file options: https://docs.mongodb.com/manual/reference/configuration-options/ 

## FILE STRUCTURE

List --dbpath directory:

> ls -l /data/db

If you are not guided by mongodb to interact with this files do not do it.

List diagnostics data directory:

> ls -l /data/db/diagnostic.data 

Diagnostic data collecte by mongodb support.

List journal directory:

> ls -l /data/db/journal

Log files to prevent data loss in case of machine failure.

List socket file:

ls /tmp/mongodb-27017.sock

## BASIC COMMANDS

**Basic Helper Groups**

- db.`method`(): This shell helper wrap commands that interact with the database.
- rs.`method`(): This shell helper wrap commands that control replica set control and management.
- sh.`method`(): This shell helper wrap commands that control sharding.

**User Management**
- db.createUser()
- db.dropUser()

**Collection Management**
- db.renameCollection()
- db.collection.createIndex()
- db. collection.drop()

**Database Management**
- db.dropDratabase()
- db.createCollection()

**Database Status**
- db.serverStatus()

**Database Command vs Shell Helper**

(Database Command)
        db.runCommand(
            {
                "createIndexes" : "<collection>",
                "indexes" : [
                    {
                        key : { "product" : 1 }
                    },
                    "name" : "name_index"
                    ]
            }
        )

(Shell Helper)
        db.`collection`.createIndex(
            { "product" : 1 },
            { "name" : "name_index" }
        )

**Database Commands**

DB commands only work with the active database.

> db.runCommand({ COMMAND })

> db.commandHelp( "command" )

**Introspect Shell Helpers**

Execute the shell helper with out the ().

> db.products.createIndex

## LOGGING BASICS

Get the logging components

> mongo admin --host 192.168.103.100:27000 -u m103-admin -p m103-pass --eval 'db.getLogComponents()'

Change the logging level:

> mongo admin --host 192.168.103.100:27000 -u m103-admin -p m103-pass --eval 'db.setLogLevel(0, "index")'

View the logs through the Mongo shell:

> db.adminCommand({ "getLog": "global" })

View the logs through the command line:

> tail -f /data/db/mongod.log

Update a document:

> mongo admin --host 192.168.103.100:27000 -u m103-admin -p m103-pass --eval 'db.products.update( { "sku" : 6902667 }, { $set : { "salePrice" : 39.99} } )'

Look for instructions in the log file with grep:

> grep -i 'update' /data/db/mongod.log

**Log Verbosity Level**

-1 = Inherit from parent
0 = Default Verbosity, to include informational messages
1-5 = Increases the verbosity level to include Debug messages

## PROFILING THE DATABASE

**Events captured by the profiler**:
- CRUD
- Administrative Operations
- Configuration Operations

**Levels of Profiler**
- 0: Default Value. The profiler is off and does not collect any data.
- 1: The profiler collects data for operations that take longer than the value of slowms. Default more than 100ms.
- 2: The profiler collects data for all operations.

Thes list all of the collection names you can run this command:

> db.runCommand({listCollections: 1])

Get profiling level:

> mongo newDB --host 192.168.103.100:27000 -u m103-admin -p m103-pass --authenticationDatabase admin --eval 'db.getProfilingLevel()'

Set profiling level:

> mongo newDB --host 192.168.103.100:27000 -u m103-admin -p m103-pass --authenticationDatabase admin --eval 'db.setProfilingLevel(1)'

Show collections:

> mongo newDB --host 192.168.103.100:27000 -u m103-admin -p m103-pass --authenticationDatabase admin --eval 'db.getCollectionNames()'

Set slowms to 0:

> mongo newDB --host 192.168.103.100:27000 -u m103-admin -p m103-pass --authenticationDatabase admin --eval 'db.setProfilingLevel( 1, { slowms: 0 } )'

Insert one documento into a new collection:

> mongo newDB --host 192.168.103.100:27000 -u m103-admin -p m103-pass --authenticationDatabase admin --eval 'db.new_collection.insert( { "a": 1 } )'

Get profiling data from system.profile:

> mongo newDB --host 192.168.103.100:27000 -u m103-admin -p m103-pass --authenticationDatabase admin --eval 'db.system.profile.find().pretty()'

## BASIC SECURITY

Authentication & Authorization

**Authentication**

Verifies the Identity of a user. Answers the question: Who are you?

**Authorization**

Verifies the privileges of a user. Answers the question:  What do you access to?

**Authentication Mechanisms**
- SCRAM: Salted challenge response authentication mechanism. It is the default method. Basically its password security. Basic security for your mongodb cluster.
- X.509: Uses an X.509 certificate for authentication.
- LDAP: (Enterprise Only) - Active Directory
- Kerberos (Enterprise Only)

**Cluster Authentication Mechanism** 
To authenticate between members of the cluster.

**Authorization: Role Based Access Controll**
- Each user has one or more roles
- Each role has one or more privileges
- A privilege represents a group of Actions and the Resources thos actions apply to.
Roles suport a high level of responsibility isolation for operational task.

Print configuration file:

> cat /etc/mongod.conf

**Localhost Exception**
- Allows you to access a MongoDB server that enforces authentication but does not yet have a configured user for you to authenticate with.
- Must run Mongo shell from same host running MongoDB server
- The localhost exception closes after you create your first user
- Always create a user with administrative privileges first.

Launch standalone mongod:

> mongod -f /etc/mongod.conf

Connect to mongod:

> mongo --host 127.0.0.1:27017

Create a new user with the root role (also, named root):

> use admin 
>
> db.createUser({ user: "root", pwd: "root123", roles: [ "root"] })

Connect to mongod and authenticate as root:

> mongo --username root --password root123 --authenticationDatabase admin

Run DB stats:

> db.stats()

Shutdown the server

> use admin
>
> db.shutdownServer()

## BUILT IN ROLES

**Roles in MongoDB**
- role Based Access Control
- Database Users are granted roles
- Custom Roles
    - Tailored roles to attend specific needs of set of users
- Built-in Roles
    - Pre-packaged MongoDB Roles
- Role Structure
    - Privileges
    - Action + Resource

A role is composed of a set of privileges that the role enables, the privilege define the action or actions that can be perform over every resource. 

A Resource can be a Database, a collection, a set of collections, a cluster (Replica Set, Shard Cluster)

        //specific database and collection
        { db: "products", collection: "inventory" }
        // all databases and all callections
        { db: "", collection: "" }
        // any database and specific collection
        { db: "products", collection: "" }
        // specific detabase any collection
        { cluster: true }

A Privilege is defined by a resource and the actions allowed over a resource
        // allow to shutdown over the cluster
        { resource: { cluster: true }, actions: [ "shutdown" ] }

A role can inherit from other roles. A role can contain network authentication restrictions
    - clientSource
    - serverAddress

**Built-In Roles**
Roles per database per user:
- Database User ( read, readWrite )
- Database Administrator (dbAdmin, userAdmin, dbOwner)
- Cluster Administrator (clusterAdmin, clusterManager, clusterMonitor, hostManager)
- Backup / Restore (backup, restore)
- Super User (root)
Roles for all database:
- Database User (readAnyDatabase, readWriteAnyDatabase)
- Database Administration (dbAdminAnyDatabase, userAdminAnyDatabase)
- Super User (root)

The ones we are going to need in this course are: dbAdmin, userAdmin, dbOwner.

Authenticate as root user:

> mongo admin -u root -p root123

Create security officer (First user you should always create):
userAdmin (changeCustomData, changePassword, createRole, createUser, dropRole, dropUser, grantRole, revokeRole, setAuthenticationRestriction, viewRole, viewUser)

> db.createUser({user: "security_officer", pwd: "h3ll0th3r3", roles [{ db: "admin", role: "userAdmin"}]})

Create database administrator:
dbAdmin (Can't read or write user data, Can do any related to data definitio language but cant write data to the database or read data).

> use admin
>
> db.createUser({ user: "dba",pwd: "c1lynd3rs",roles: [ { db: "m103", role: "dbAdmin" } ]})

Grant role to user:

The role dbOwner is a database owner, can perform any administrative action on the database. This role combines the privileges granted by the readWrite, dbAdmin and userAdmin roles.

> db.grantRolesToUser( "dba",  [ { db: "playground", role: "dbOwner"  } ] )

Show role privileges:

> db.runCommand( { rolesInfo: { role: "dbOwner", db: "playground" }, showPrivileges: true} )

## SERVER TOOLS OVERVIEW

List mongod binaries:

> find /usr/bin -name `"mongo*"`

Create new dbpath and launch mongod:

> mkdir -p ~/first_mongod
>
> mongod --port 30000 --dbpath ~/first_mongod --logpath ~/first_mongod/mongdb.log --fork

**Mongstat**
An utility designed to run quick statistics on a mongodb or mongos process.

Use mongstat to get stats on a running mongd process:

> mongstat --help
>
> mongostat --port 30000

**Mongorestore & Mongodump**
To import and import dumps from mongdb.

Use mongdump to get a BSON dump of a MongoDB collection:
> mongdump --help
>
> mongodump --port 30000 -u 'm103-admin' -p 'm103-pass' --authenticationDatabase 'admin' --db applicationData --collection products 
>
> ls dump/applicationData/ 
>
> cat dump/dump/applicationData/products.metadata.json

Use mongorestore to restore a MongoDB collection from a BSON dump:

> mongorestore --drop --port 30000 dump/

Use mongoexport to export a MongoDB collection to JSON or CSV (or stdout):

> mongoexport --help
>
> mongoexport --port 30000 -u 'm103-admin' -p 'm103-pass' --authenticationDatabase 'admin' --db applicationData --collection products
>
> mongoexport --port 30000 -u 'm103-admin' -p 'm103-pass' --authenticationDatabase 'admin' --db aplicationData --collection products -o products.json

Tail the exported JSON file:

> tail products.json

Using mongoimport to create a MongoDB collection from a JSON or CSV file:

> mongoimport --port 30000 -u 'm103-admin' -p 'm103-pass' --authenticationDatabase 'admin' products.json

