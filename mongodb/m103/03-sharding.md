# WHAT IS SHARDING?

Vertical scaling can become very expensive.

MongoDB can Scale Horizontally. Distributing the data between various machines. The way data is distributed in mongodb is sharding. Creating a Sharded Cluster. Queries can become a little trickier. Client have to connect to Mongos instead of connected to a cluster. Mongos uses the metadata stored in the config servers to determine which cluster have the data the query needs. The config servers are also a replica set of 3 servers.

Sharded Cluster: Contains the Shards where the data lives.
Shards: Store distributed collections.
Config Server: Stores the metadata about each shard.
Mongos: Routes the queries to the correct shards.

# WHEN TO SHARD

First check if it is economically viable to vertically scale. (Indicators: Throughput, Speed, Volume). Evaluate if you can add more CPU, Network, RAM or Disk to your nodes.

Consider Operational Impact on Scalability. Horizontal Scale and Distribution of data might allow Process Parallelization on backup, restore and initial sync. Individual server should have between 2 - 5 TB of data, more than that, consider sharding.

There are workloads that intrisecally play nicer in distributed operations.
- Single Thread Operations
- Geographical Distributed Data
- Aggregation Fremework Commands (Aggregation Pipeline Commands): Not all stages of your pipeline are parallelizable. Understand your pipeline.
- Zone Sharding: Geographical distribution.

# SHARDING ARCHITECTURE

We can add any number of shards. We setup a route process called mongos that routes the data to the corresponding shard. The client sends the queries to mongos not to the shards.

Mongos uses the metadata around the shards to route the queries. The metadata is not stored in mongos, it is stored in config servers. 

On a sharded cluster we also have a primary shard to store all those collections that are not sharded. And to handle merging operations.

SHARD_MERGE: When mongos does not know on which shard to look it sends the querie to all the shards and then it has to merge all the results. This stage can take place con mongos or a randomly chosen shard in the cluster.

# SETTING UP A SHARDED CLUSTER

Starting the three config servers:

> mongod -f csrs_1.conf
>
> mongod -f csrs_2.conf
>
> mongod -f csrs_3.conf

Connect to one of the config servers:

> mongo --port 26001

Initiating the CSRS:

> rs.initiate()

Creating super user on CSRS:

> use admin
>
> db.createUser({ user: "m103-admin", pwd: "m103-pass", roles [ { role: "root", db: "admin" } ] } )

Authenticating as the super user:

> db.auth("m103-admin", "m103-pass")

Add the second and third node to the CSRS:

> rs.add(192.168.103.100:26002")
>
> rs.add(192.168.103.100:26003")

Start the mongos server:

> mongos -f mongos.conf

Connect to mongos:

> mongo --port 2600 --username m103-admin --password m103-pass --authenticationDatabase admin

Check sharding status:

> sh.status()

Updated configuration (node1.conf, node2.conf, node3.conf)

Connecting directly to secondary node (note that if an election has taken place in your replica set, the specified node may have become primary):

> mongo --port 27012 -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin"

Shutting down node:

> use admin
>
> db.shutdownServer()

Restarting node with new configuration:

> mongod -f node2.conf

Stepping down current primary:

> rs.stepDown()

A rolling upgrade, stop first secondary and start it with new configuration. stop second secondary and start it with new configuration. Step down primary, stop it and start it with new config. 

Adding new shard to cluster from mongos:

> sh.addShard("m103-repl/192.158.103.100:27012")

To create a sharded cluster we need at least a replica set (3 nodes), a configuration server (csrs: 3 nodes), a mongos.

# CONFIG DB

Very important database in the sharded cluster. You should generally never write any data to it, It is runned and mainteined internally by mongod. It has usefull information so we can read from it.

To see the topology of the sharded cluster:

> sh.status()

Switch con config DB:

> use config

Query config.databases: (Returns each database in our sharded cluster as one document)

> db.databases.find().pretty()

Query config.collections: (This gives us information of the collections that have been sharded)

> db.collections.find().pretty()

Query config.shards:

> db.shards.find().pretty()

Query config.chunks: (Chunks min value, and max value to select a shard)

> db.chunks.find().pretty()

Query config.mongos: (It can be multiple mongos services here)

> db.mongos.find().pretty()

# SHARD KEYS

This is the index field or fields that mongodb uses to partition data in a sharded collection and distribute it across the shards in your cluster. The groups in which mongodb divides the documents are refered as chunks.

Your shard keys must be present in any document of your collection. The shard key should be present in any querie, without it mongos has to querie each shard of your cluster.

- Shard key fields must be indexed
    - Indexes must exist first before you can select the indexed fields for your shard key
- Shard keys are immutable. Sharding is permanent.
    - You cannot change the shard key field post-sharding
    - You cannot change the values of the shard key fields post-sharding
- Shard Keys are permanent
    - You cannot unshard a collection.

## HOW TO SHARD

1. Use sh.enableSharding("`<database>`") to enable sharding for the specified database. Does not automatically shard your collections, just marks them as eligible for sharding.
2. Use db.collection.createIndex() to create the index for your shard key fields.
3. Use sh.shardCollection("`<database>.<collection>`, { shard key } ) to shard the collection.

Connect to mongos and run:

> sh.status()
>
> show dbs

Show collections in m103 database:

> use m103
>
> show collections

Enable sharding on the m103 database:

> sh.enableSharding("m103")

Find one document from the products collection, to help us choose a shard key:

> db.products.findOne()

Create an index on sku:

> db.products.createIndex( { "sku" : 1 } )

Shard the products collection on sku

> sh.shardCollection("m103.products", { "sku" : 1 } )

Checking the status of the sharded cluster:

> sh.status()

**Recap**

- Shard Keys determine data distribution in a sharded cluster
- Shard keys are immutable
- Shard keys values are immutable
- Create the underlying index first before sharding on the indexed field or fields.

# PICKING A GOOD SHARD KEY

The goal is a shard key whose values provides good write distribution.
- High Cardinality: (Lots of unique possible values)
- Low Frequency: (very little repetition of those unique values)
- Non-Monotonic Changing: (non-linear change in value)

## CARDINALITY

The chosen shard key should have high cardinality. 

High Cardinality = Many possible unique shard key values.

## FREQUENCY

High Frequency = Low repetition of a given unique shard key value.

## TYPE OF CHANGE

Avoid shard keys that change monotonically. When the key changes in a predictable and steady way. Like dates or timestamps, id key.

## READ ISOLATION

Which shard has the data that meets our query parameter? Mongodb chan direct my read to the shard that contains the data (if the querie includes the key).

Without the shard key to guide it, mongodb has to querie each shard. These queries can be pretty slow.

## SHARDING IS A PERMANENT OPERATION

- You cannot unshard a collection once sharded.
- You cannot update the shard key of a sharded collection.
- You cannot update the values of the sharded key for any document in the sharded collection.
- Test your shard keys in a staging environment first before sharding in production environments.

## RECAP

- Good shard keys provide even write distribution.
- Where possible, good shard keys provide read isolation
- High Cardinality, Low Frequency shard key values ideal
- Avoid monotonically changing shard keys
- Unsharding a collection is hard - avoid it!

# HASHED SHARD KEYS

A shard key where the underlying index is hashed. Mongodb hashes the key to decide the shard where to store the key. 

Hashed shard keys provide more even distribution of monotonically-changing shard keys. 

## HASHED SHARD KEY CONSIDERATIONS

- Queries on ranges of shard key values are more likely to be scatter-gather.
- Cannot support geographically isolated read operations using zoned sharding.
- Hashed index must be on a single non-array filed
- Hashed indexes don't support fast sorting

## SHARDING USING A HASHED SHARD KEY

1. Use sh.enableSharding("`<database`") to enable sharding for the specified database.
2. Use db.collection.createIndex( { "`<field>`" : "hashed" } ) to create the index for your shard kye fields.
3. Use sh.shardCollection("`<database>.<collection>`", { `<shard key field>` : "hashed" } ) to shard the collection.

## RECAP

- Even deistribution of shard keys on monotonically changing fields like dates.
- No fast sorts, targeted queries on ranges of shard key values, or geographically isolated workloads
- Hashed indexes are single field, non-array

# CHUNKS

The config database has the mapping of the chunks to shards. The min a max values of the chunks are importants. Al documents of the same chunk will be in the same shard.

CunkSize = 64 MB

1MB <= ChunkSize <= 1024MB

The ChunkSize is configurable in runtime.

Show collections in config database:

> use config
>
> show collections

Find one document from the chunks collection:

> db.chunks.findOne()

Change the chunk size:

> use config
>
> `db.settings.save({_id: "chunksize", value: 1})`

Value is the size of the chunk in MB.

Check thes tatus of the sharded cluster:

> sh.status()

Import the new products.part2 dataset into MongoDB:

> mongoimport /dataset/products.part2.json --port 26000 -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin" --db m103 --collection products

## SHARD KEY VALUES FREQUENCY

The chosen shard key wasnt that good after all. 90% of our new documents have the same sharkd key value. This will cause an abnormal situation known as Jumbo Chunks.

**Jumbo Chunks**

- Larger than the defined chunk size.
- Cannot move jumbo chunks
    - Once marked as jumbo the balnacer skips these chunks and avoids trying to move them.
- In some cases these will not be able to be moved or split.

## RECAP:

- Logical groups of documents. min bound inclusive, max bound inclusive.
- Chunk can only live at one designated shard at a time.
- Shardk key cardinality/frquency, chunk size will determine number of chunks.

# BALANCING

The mongodb balancer identifies which shards have more documents than others and tries to balance the data between the shards. 

Currently, the balancer process runs on the primary members of the config servers replica set. If the balancer process detects imbalances it starts a balncer round. The balancer round can migrate data in parallel. A shard can only prarticipate in one migration at a time. floor(n / 2).

The balancing round hapens consecutebly until the palancer process detects the shards are balaced.

## BALANCER MANAGEMENT METHODS

Start the balancer:

> sh.startBalancer(timeout, interval)

Stop the balancer:

> sh.stopBalancer(timeout, interval)

Enable / Disable the blancer:

> sh.setBalancerState(boolean)

## RECAP

- Balancer is responsible for evenly distributing chunks of data across the sharded cluster.
- Balancer runs on Primary member of config server replica set since mongodb 3.4.0
- Balancer is an automatic process and requires minimal user configuration.

# QUERIES IN A SHARDED CLUSTER

How mongos routes data across the sharded cluster. Mongos is the principal interface point for your client application. All queries should be pointed to mongos.

1. Mongos determines the list of shards that must receive the query. Targeted vs Scatter Gather Queries.
2. Mongos opens a cursor against each of the targeted shards. Each cursor executes the query predicate and returns the data.
3. Mongos merges the return of the queries and return the data to cthe client.

## SORT, LIMIT AND SKIP IN SHARDED CLUSTERS

- sort(): The mongos pushes the sort to each shard and merge-sorts the results.
- limit(): The mongos passes the limit to each targeted shard, the re-applies the limit to the merged set of results.
- skip(): The mongos performs the skip against the merged set of results.

## RECAP:

- mongos handles all queries in the cluster.
- mongos builds a list of shards to target a query
- mongos merges the results from each shard
- mongos supports standard query modifiers like sort, limit and skip.

# TARGETED QUERIES VS SCATTER GATHER

The config server has a table of the chunks and where is each chuked located in the shards. The mongos keeps a cached copy of this metadata table. Each mongos has a map of which shard contains the chunks. Whe mongos receives a query whose predicate contains the shard key, mongos can look the metadata table and send the query to the shard that contains the data. 

Range queries on a hashed key are almost always scatter gather queries.

**When you use a compound index  as shard key:**
Shard Key: { "sku" : 1, "type" : 1, "name" : 1 }

Targetable queries:
- db.products.find( { "sku" : ... } )
- db.products.find( { "sku" : ..., "type" : ... } )
- db.products.find( { "sku" : ..., "type" : ... , "name" : ... } )

Scatter-gather queries:
- db.products.find( { "type" : ... } )
- db.products.find( { "name" : ... } )

Show collections in the m103 database:

> use m103
>
> show collections
>
> sh.status()

Targeted query with explain() output:

> db.products.find( { "sku" : 1000000749 }).explain()

- stage: FETCH

Scatter gather query with explain() output:

> db.products.find( { "name": "Gods And Heroes: Rome Rising - Windows [Digital Download]" }).explain()

- stage: SHARD_MERGE

## RECAP:

- Targeted queries require the shard key in the query
- Ranged queries on the shard key may still require targeting every shard in the cluster.
- Without the shard key, the mongos must perform a scatter-gather query

