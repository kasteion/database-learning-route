# Read Concerns

Similar to Write Concerns.

- Represent different levels of "read isolation". (Low read isolation means a client can read the data before it has been writen to the majority of the nodes)
- Can be used to specify a consistent view of the database.

Read Concern "local" returns data that only has been writen on the primary. It is the default read concern. The client might read data that can be rolled back in the case of the primary going down. This does not check that data has been replicated.

Read Concern "majority" returns data that has been replicated to the majority of the nodes.

# Bulk Writes

This is to avoid writing data one at a time. Like sending a Shopping cart items to the database one by one vrs sending them in bulk.

db.stock.bulkWrite([{...}, {...}, {...}])

Limiting the effect of latency in overall operation time.

Bulk Writes in MongoDB are ordered by default. Executes writes sequentially. Will end execution after first write failure.

It might be the case our write operations are not dependent one of the other. We can send the ordered: false and if an operation fails mongodb will keep writing the rest of the items.

db.stock.bulkWrite([{...}, {...}, {...}], { ordered: false})

Unordered bulk write has to be specified wit the flag: { ordered: false } and it executes writes in parallel. A single failure does not affect the rest of the writes.

Bulk writes allow database clients to send multiple writes. Can either be ordered or unordered.

http://mongodb.github.io/node-mongodb-native/3.1/tutorials/crud/#bulkwrite
