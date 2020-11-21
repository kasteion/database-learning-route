# WHAT IS REPLICATION?

Replication makes your data more durable. Mongodb uses Asinchronous Statement Base Replication because it is platform independent and allows more flexibility between replica set.

Replication is the concept of maintaining multiple copies of your data. The main reason that replication is necesary is because you can't asume that all of your servers will be available (Maintenance, Desasters). Your servers will experience downtime sooner or later. The point of replication is that you can still access your data (Availability). 

A server that does not uses replication is an one node or stand alone deployment.

In a Replicated solutions we have a couple extra nodes at hand an they hold copies of our data. In mongodb a group of servers that have copies of the same data is called a Replica Set.  In a Replica Set all data is handled by one node (Primary) and is up to the remaining nodes to replicate de data (Secundary Nodes). The goal here is to maintain the data consistent and if the primary node fails one of the secundary nodes can take its place (Failover process). The secundary nodes vote (Election) to decide which node wil take up. When the failed node is operative again, becomes a secundary node and starts replicatind the data from the primary node.

**Binary Replication**
Checks the bytes that changed and records them in a binary log. Each secundary node get the binary log and recods the canges in the same location. Replicating data this way is pretty easy in the secundary. Using binary replication asumes that the OS is the same in each machine of the cluster. 
    - Less data
    - Faster
   
**Statement Base Replication**
After the write is completed in the primary node. The write is stored in the primary Oplog. The Secondaries sync their Oplog with the primary Oplog and replay any new statements in the new data. This works if the OS os Instruction Sets in the replica set.
    - **Idempotence**: Even if you apply an Oplog many times you obtain the same result. If the operations was to add 1 to a counter changing the counter from 1000 to 1001. The operation in the Oplog gets transformed into a statemet that sets the counte to 1001.
    - Not bound by operating system, or any machine level dependency.

# MONGODB REPLICA SET

Replica Sets are groups of mongod that share copies of the same infomation between them. They can be of one of two roles: Primary or Secundary Nodes. The data is replicated based on a protocol... Asynchronous Replication Protocol (Protocol Version 1 PV1: Based on the raft protocol - previous versions of mongodb may used PV0).

Every mongodb instances has a operation log (OpLog). An Idempotent operation can be applied multiple times and keemp the data consistent. 

A primary data can be configured as an arbiter
    - Hods no data
    - Can vote in an election (Tie breaker)
    - Cannot become primary

You should always have at least an odd number of nodes in the replica set. Any topology change triggers an election. Adding members to the set, Failing members or changing any of the replica set configuration aspects will be perceived as a topology change.

Replica sets can go up to 50 members, but only 7 of those can be voting members (One will become primary, the other 6 will be secondary). Avoid Arbiters as they can cause problem. You can have Hidden nodes or Delayed nodes to avoid recovery from backup (Hot Backups)

About Raft Protocol:
http://thesecretlivesofdata.com/raft/
https://raft.github.io/

# SETTING UP A REPLICA SET

We will begin by lauching three mongo db independent processes. They will not be able to comunicate between each other until we connect them and then they can start the replication process. 

Adding this line to the configuration file 

```
keyFile: /var/mongodb/pki/m103-keyfile
```

We enable key file auth between cluster members.

Creating the key file and setting permissions on it:

> sudo mkdir -p /var/mongdb/pki/
>
> sudo chown vagrant:vagrant /var/mongodb/pki/
>
> openssl rand -base64 741 > /var/mongdb/pki/m103-keyfile
>
> chmod 400 /var/mongdb/pki/m103-keyfile

Creating the dbpath for node1:

> mkdir -p /var/mongodb/db/node1

Starting a mongd with node1.conf

> mongod -f node1.conf

Compyng node1.conf to node2.conf and node2.conf

> cp node1.conf node2.conf
>
> cp node1.conf node3.conf

Editing node2.conf using vi:

> vi node2.conf

> vi node3.conf

Change path, port and logpath

Creating the data directories for node2 and node3:

> mkdir /var/mongod/db/{node2,node3}

Starting mongd processes with node2.conf and node3.conf

> mongod -f node2.conf
>
> mongod -f node3.conf

Connecting to node1:

> mongo --port 27011

Initiating the replica set:

> rs.initiate()

Creating a user:

> use admin 
>
> db.createUser({ user: "m103-admin", pwd: "m103-pass", roles: [ {role: "root", db: "admin"} ]})

Exiting out of the Mongo shell and connecting to the entire replica set... in this command `m103-example` is the name of the replica set:

> exit
>
> mongo --host "m103-example/192.168.103.100:27011" -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin"

Getting replica set status:

> rs.status()

Adding other members to replica set:

> rs.add("m103:27012")
>
> rs.add("m103:27013")

Getting an overview of the replica set topology:

> rs.isMaster()

Stepping down the current primary:

> rs.stepDown()

Checking replica set overview after election:

> rs.isMaster()

# REPLICATION CONFIGURATION DOCUMENT

- JSON Object that defines the configuration options of our replica set (BSON Document)
- Can be configured manually from the shell
- There are set of mongo shell replication helper methods that make it easier to manage.

**Shell Helpers**: rs.add, rs.initiate, rs.remove, rs.reconfig, rs.config

```
{
    _id: m103-example,
    _version: 1,
    members: [
        {
            _id: 1,
            host: m103:27017,
            arbiterOnly: false,
            hidden: false,
            priority: 1,
            slaveDelay: <int>,
        },
        ...
    ],
}
```

- Replication Config Document is used to define our Replica Set.
- Members field determine the topology and roles of the individual nodes
- Basic set of config options

# REPLICATION COMMANDS

Commands to get information of a replica set:

**rs.status()**
- Reports health on replica set nodes.
- Uses data from heartbeats. It can be seconds behind.
- Gives us the most information for each specific node.

**rs.isMaster()**
- Describes a node's role in the replica set
- Shorter output than rs.status()

**db.serverStatus()['repl']**
- Section of the db.serverStatus() output
- Similiar to the output of rs.isMaster()

**rs.printReplicationInfo()**
- Only returns oplog data relative to current node
- Contains timestamps of the first and last oplog events.

# LOCAL DB

Make a data directory and launch a mongod process for a standalone node:

> mkdir allbymyselfdb
>
> mongod --dbpath allbymyselfdb

Dispaly all databases (by default, only admin and local):

> mongo
>
> show dbs

Display collections from the local database (this displays more collections from a replica set than from a standalone node):

> use local
>
> show collections
>
> db.oplog.rs.find()

Get information about the oplog (remember the oplog is a capped collection).

Store oplog stats as a variable called stats:

> var stats = db.oplog.rs.stats()

Verify that this collection is capped (it will grow to a pre-configured size before it starts to overwrite the oldest entries with newer ones):

> stats.capped

Get current size of the oplog:

> stats.size

Get size limit of the oplog:

> stats.maxSize

Get current oplog data (including first and last events times, and configured oplog size):

> rs.printReplicationInfo()

**oplog.rs**
- Capped Collection
- Replication Window is proportional to the system load
- One operation may result in many oplog.rs entries

Don't mess around to much with this collections (In the local database)
- me
- oplog.rs
- replset.election
- replset.minvalid
- startup_log
- system.replset
- syste.rollback.id

**Recap**
- Local database holds important information and should not be mess with.
- oplog.rs is central to our replcation mechanism
- The size of our oplog will impact the replication window
- Any data written to our local database does not get replicated to other nodes.

Create new namespace m103.messages:

> use m103
>
> db.createCollection('messages')

Query the oplog, filtering out the heartbeats ("periodic noop") and only returning the latest entry:

> use local
>
> b.oplog.rs.find( { "o.msg": { $ne: "periodic noop" } } ).sort( { $natural: -1 } ).limit(1).pretty()

Insert 100 different documents:

> use m103
>
> `for ( i=0; i< 100; i++) { db.messages.insert( { 'msg': 'not yet', _id: i } ) }` 
>
> db.messages.count()

Query the oplog to find all operations related to m103.messages:

> use local
>
> db.oplog.rs.find({"ns": "m103.messages"}).sort({$natural: -1})

Illustrate that one update statement may generate many entries in the oplog:

> use m103
>
> db.messages.updateMany( {}, { $set: { author: 'norberto' } } )
>
> use local
>
> db.oplog.rs.find( { "ns": "m103.messages" } ).sort( { $natural: -1 } )

Remember, even though you can write data to the local db, you should not.

# RECONFIGURE A RUNNING REPLICA SET

Starting up mongod processes for our fourth node and arbiter:

> mongod -f node4.conf
>
> mongod -f arbiter.conf

From the Mongo shell of the replica set, adding the new secondary and the new arbiter:

> rs.add("m103:27014")
>
> rs.addArb("m103:28000")

Checking replic set makeup after adding two new nodes:

> rs.isMaster()

Removing the arbiter from our replica set:

> rs.remove("m103:28000")

Assigning the current configuration to a shell variable we can edit, in order to reconfigure the replica set

> cfg = rs.conf()

Editing our new variable `cfg` to change topology - specifically, by modifying `cfg.members`:

> cfg.members[3].votes = 0
>
> cfg.members[3].hidden = true
>
> cfg.members[3].priority = 0

Updating our replica set to use the new configuration `cfg`:

> rs.reconfig(cfg)

# READS AND WRITES ON A REPLICA SET

Connecting to the replica set:

> mongo --host "m103-example/m103:27011" -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin"

Checking replica set topology:

> rs.isMaster()

Inserting one documento into a new collection:

> use newDB
>
> db.new_collection.insert({"student": "Matt Javaly", "grade": "A+"})

Connecting directly to a secondary node (this node may not be a secondary in your replica set):

> mongo --host "m103:27012" -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin"

Attempting to execute a read command on a secondary node (this should fail)

> show dbs

Enabling read commands on a secondary node:

> rs.slaveOk()

Reading from a secondary node:

> use newDB
>
> db.new_collection.find()

Attempting to write data directly to a secondary node (this should fail, because we cannot write data directly to a secondary):

> db.new_collection.insert({"student": "Norberto Leite", "grade": "B+"})

Shutting down the server (on both secondary nodes)

> use admin
>
> db.shutdownServer()
>
> rs.status()

Connecting directly to the last healthy node in our set:

> mongo --host "m103:27011" -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin"

Verifying that the las tnode stepped down to become a secondary when a majority of nodes in the set where not available:

> rs.isMaster()

# FAILOVERS AND ELECTIONS

Rolling Upgrades (Update the secondary nodes, and then upgrade the primary) This will trigger an election... This will happen anyway so we can trigger an election with:

> rs.stepDown()

Any change in topology will trigger an election that may o may not change the primary node. A change in the primary node will happen if the primary goes down or if the primary steps down. The posibility of a secondary node becoming primary will of the node priority and the if the data of the node is up to date.

Storing replica set configuration as a variable cfg:

> cfg = rs.conf()

Setting the priority of a node to 0, so it cannot become primary (making the node "pasive"):

> cfg.members[2].priority = 0

Updating our replica set to use the new configuration cfg:

> rs.reconfig(cfg)

Checking the new topology of our set:

> rs.isMaster()

Forcing an election in this replica set (although in this case, we rigged the election so only one node could become primary):

rs.stepDown()

Checking the topology of our set after the election:

> rs.isMaster()

# WRITE CONCERN

Is an acknowlegment mechanism that developers add to write operations. Higher level of acknowlegment produce a stronger durability garanty.

Durability means that the write has propagated to the number of replica set member nodes specified in the write concern. The more number of replica set nodes that acknowledge the success of a write the more likely that the write is durable in the event of a failure.

Mayority is defined as a simple mayority of replica set members (Divide by 2 and round up).

The trade off with increase durability is time. More durability requires more time to achieve the write concern level.

## WRITE CONCERN LEVELS

0 - Don't wait for acknowledgement
1 (default) - Wait for acknowledgement from the primary only.
2 and up - Wait for acknowledgement from the primary and one or more secondaries
"majority": Wait for acknowledgement from a majority of replica set members.

## ADDITIONAL WRITE CONCERN OPTIONS

- wtimeout: (int) - The time to wait for the requested write concern before marking the operation as failed.
- j: `true | false` - Requires the nodes to commit the write operation to the journal before returning an acknowledge. (Stronger garantee that the writes where received and written to a journal)

## WRITE CONCERN COMMANDS

The core write commands support write concert:

- Insert
- Update
- Delete 
- findAndModify

```
db.products.insert(
    {...},
    {
    writeConcert : [ w: "majority", wtimeout: 60 ]
    }
)
```
- Write Concern is a system of acknowledgements that provides a level of durability guarantee.
- The trade off higher write concern levels is the speed at which writes are committed.
- MongoDB supports write concern for all cluster types: standalone, replica set, and sharded clusters.

# READ CONCERN

Is a companion to write concern. Is an acknowledgement mechanismo to read operations. Return documents that meet the requested durability garanty.

Helps with the issue of data durability during failover events. Lets your operation return only data that has meet certain durability.

## READ CONCERN LEVELS

- local: Returns the most recent data in the cluster. Is the Default. There is no garantee that the data will be saved during a failover event.
- available (sharded clusters): The same as local read for replica set deployment. The default for read operations against secondary members. The main difference is in the context of sharded clusters.
- majority: Only returns data that has been aknowledge as been written to a majority of nodes. Provides the stronger garantee but the tradeof is that you may not get the freshest data.
- linearizable: Provides read you own write functionality.

It depends:

Fast - Safe - Latest (Pick two).

Fast & Latest: Use Local & Available (No durability guarantee).

Fast & Safe: Use majority (Reads are not guaranteed to be the latest written data)

Safe & Lates: Linearizable (Reads may be slower than other read concerns, Single document reads only)

# READ PREFERENCE

Allows your applications to route you reads to a specific member of a replica set. 

By default your applications read and write data from your primary. What if we want our applications to read from a secundary?

## READ PREFERENCE MODES

- pimary(default): All reads to the primary only.
- primaryPreferred: All reads to primary but if there is no primary available it routes to a secondary.
- secondary: All reads to secondary.
- secondaryPreferred: All reads to secondary but if there is no secondary available it routes to a secondary.
- nearest: Routes reads to the node with least network latency. Geographical.

Recap:
- Read preference lets you route read operations to specific replica set members.
- Every read preference other than primary can return stale reads.
- nearest supports geographically local reads.

