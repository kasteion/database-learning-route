# AGGREGATION PERFORMANCE

https://docs.mongodb.com/manual/core/query-plans/

- Index Usage
- Memory Constraints

Two highlevel categories of aggregation queries.

**"Realtime" Processing Queries**
- Provide data for applications
- Query performance is more important

**Batch Processing**
- Provide data for analytics done at periods of time
- Query performance is less important

**Index Usage**
Index are a vital part of a good query performance. And the same applies to aggregation queries. Index Usage is a bit different on an aggregation pipeline than normal index usage. In an aggregation operation the output of a stages goes into the input of the next stage... using the indexes it can until it gets to a stage that cannot use the indexes, from there on the next stages will not use the indexes. The query optimizer tries to take advantage of every index by defining which stages can be moved.

```
db.orders.aggregate([
    {
        stage1
    },
    {
        stage2
    },
    ...
], { explain: true})
```

Wi will be working with the hipotetical orders collection.

```
db.orders.createIndex({ cust_id: 1})
```

$match operator is able to utilize indexes, specially if it is at the begining of a pipeline. We want to see operators that use indexes at the front of our pipelines. 

```
db.orders.aggregate([
    {
        $match: { cust_id: { $lt: 50 }}
    }
])
```

Similarly we will want to put $sort stages at the front of the pipeline.

```
db.orders.aggregate([
    {
        $match: { cust_id: { $lt: 50 }}
    },
    { 
        $sort: {
            total: 1
        }
    }
])
```

If your using a limit and a sort. Make shure you put them together and at the front of our pipelines.

(top-k sorting algorithm)
```
db.orders.aggregate([
    {
        $match: { cust_id: { $lt: 50 }}
    },
    {
        $limit: 10
    },
    { 
        $sort: {
            total: 1
        }
    }
])
```

**Memory Constraints**

- Results are subject to 16MB document limit, this limit does not apply to documents as they flow throught the pipeline.
    - Use $limit and $project to reduce your resulting document size.
- For each stage in our pipeline have a 100MB of RAM limit
    - Use indexes
    - db.orders.aggregate([...], { allowDiskUse: true}) as a last result mesurement since it decrease performance.
        - Doesn't work with $graphLookup (Not supported)

# AGGREGATION PIPELINE ON A SHARDED CLUSTER

**How it works**

When we run aggregation queries on an sharded cluster, since our data is partitioned it is slightly more dificult to execute them.

```
sh.shardCollection(m201.restaurants, { "address.state": 1})

db.restaurants.aggregate([
    {
        $match: { 'address.state': 'NY' }
    },
    {
        $group: {
            _id: '$address.state',
            avgStars: { $avg: '$stars' }
        }
    }
])
```
In this querie some computing needs to be done in each shard.

```
db.restaurants.aggregate([
    {
        $group: {
            _id: '$address.state',
            avgStars: { $avg: '$stars' }
        }
    }
])
```

With this stages the primary shard will do the merging
- $out
- $facet
- $lookup
- $graphLookup

**Optimizations**

```
db.restaurants.aggregate([
    {
        $sort: { stars: -1 }
    },
    {
        $match: { cuisine: 'Sushi' }
    }
])

/*The query optimizer will move the match in front of the sort */

db.restaurants.aggregate([
    {
        $match: { cuisine: 'Sushi' }
    },
    {
        $sort: { stars: -1 }
    }
])

db.restaurants.aggregate([
    {
        $skip: 10
    },
    {
        $limit: 5
    }
])

/* The query optimizer moves it like this */
db.restaurants.aggregate([
    {
        $limit: 15
    },
    {
        $skip: 10
    }
])

db.restaurants.aggregate([
    {
        $limit: 10
    },
    {
        $limit: 5
    }
])

/* The query optimizer combines the stages together.

db.restaurants.aggregate([
    {
        $limit: 5
    }
])

db.restaurants.aggregate([
    {
        $skip: 10
    },
    {
        $skip: 5
    }
])

db.restaurants.aggregate([
    {
        $skip: 5
    }
])

db.restaurants.aggregate([
    {
        $match: { cuisine: 'Sushi' }
    },
    {
        $match: { stars: 5.0 }
    }
])

db.restaurants.aggregate([
    {
        $match: { 
            cuisine: 'Sushi',
            stars: 5.0
        }
    }
])
```

All these optimizations will be automatically be attempted by the query optimizer.

# PIPELINE OPTIMIZATION

- $map
- $reduce
- $filter
- Project Accumulator Expressions

**Summary**

- Avoid unnecessary stages, the Aggregation Framework can project fields automatically if final shape of the output document can be determined from initial input.
- Use accumulator expressions, $map, $reduce, and $filter in project before an $unwind if possible.
- Every high order array function can be implemented with $reduce if the provided expressions do not meet your needs.


```
db.air_routes.findOne()

db.air_alliances.findOne()

db.air_routes.aggregate([
    {
        $match: {
            src_airport: { $in: ["JFK", "LHR"]},
            dst_airport: { $in: ["JFK", "LHR"]}
        }
    },
    {
        $group: {
            _id: "$airline.name",
        }
    },
    {
      $lookup: {
        from: "air_alliances",
        "localField": "_id",
        "foreignField": "airlines",
        "as": "alliance"
      }
    }, 
    {
        $project: {
            _id: 0,
            airline: "$_id",
            alliance: {
                $reduce: {
                    input: "$alliance.name",
                    initialValue: "",
                    in: { $concat: ["$$value", "$$this"]}
                }
            }
        }
    },
    {
        $bucketAuto: {
            groupBy: "$alliance",
            buckets: 3
        }
    }
]).pretty()
```