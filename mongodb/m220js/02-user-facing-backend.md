# Cursor Methods and Aggregation Equivalents

Follow along with test/lessons/cursor-methods-agg-equivalents.spec.js

```javascript
//Limit

const limitedCursor = movies
  .find({ directors: "Sam Raimi" }, { _id: 0, title: 1, cast: 1 })
  .limit(2);

//Is the same as

const limitPipeline = [
  { $match: { directors: "Sam Raimi" } },
  { $project: { _id: 0, title: 1, cast: 1 } },
  { $limit: 2 },
];

const limitedAggregation = await movies.aggregate(limitPipeline);

//Sort

const sortedCursor = movies
  .find({ directors: "Sam Raimi" }, { _id: 0, title: 1, cast: 1 })
  .sort([["year", 1]]);

//Is the same as

const sortPipeline = [
  { $match: { directors: "Sam Raimi" } },
  { $project: { _id: 0, title: 1, cast: 1 } },
  { $sort: { year: 1 } },
];

const sortedAggregation = await movies.aggregate(sortPipeline);

// Skiping

const skippedCursor = movies
  .find({ directors: "Sam Raimi" }, { _id: 0, title: 1, cast: 1 })
  .sort([["year", 1]])
  .skip(5);

const regularCursor = movies
  .find({ directors: "Sam Raimi" }, { _id: 0, title: 1, cast: 1 })
  .sort([["year", 1]]);
const result = (await regularCursor.toArray()).slice(5);

// Is the same as

const skipPipeline = [
  { $match: { directors: "Sam Raimi" } },
  { $project: { _id: 0, title: 1, cast: 1 } },
  { $sort: { year: 1 } },
  { $skip: 5 },
];

const regularPipeline = [
  { $match: { directors: "Sam Raimi" } },
  { $project: { _id: 0, title: 1, cast: 1 } },
  { $sort: { year: 1 } },
];
```

The cursor returned by the Node.js driver allows the following methods to be performed:

- .limit()
- .sort()
- .skip()

These methods can be chained together if necessary.

We can also perform these actions, with the following stages, in the Aggregation Framework:

- $limit
- $sort
- $skip

# Basic Aggregation

- Aggregation is a pipeline
  - Pipelines are composed of stages, broad units of work.
  - Within stages, expressions are used to specify individual units of work.
- Expressions are functions. Let's look at a function called add in Python, Java, JavaScript, and the Aggregation framework.

```python

def add(a, b):
    return a + b
```

```java
static <T extends Number> double add(T a, T b) {
    return a.doubleValue() + b.doubleValue();
}
```

```javascript
function add(a, b) {
  return a + b;
}
```

```
# Aggregation

{ "$add": [ "$a", "$b" ] }
```

Using Compass Aggregation Pipeline Builder feature, we can easily create, delete and rearrange the stages in a pipeline, and evaluate the output documents in real time. Then we can produce a version of that pipeline in Python, Java, C# or Node.js using Compass Export-to-Language feature.

# Basic Writes

Follow along with test/lessons/basic-writes.spec.js

The two idiomatic methods for inserting documents are insertOne and insertMany.

Trying to insert a duplicate \_id will fail with an error.

As an alternative to inserting, we can specify an upsert in an update operation.

# Write Concerns

**writeConcern: { w: 1}**

- Only requests an acknowledgement that **one** node applied the write. Only the Primary.
- This is the default writeConcern in MongoDB.

**writeConcern: { w: 'majority'}**

- Requests acknowledgement that a **majority of nodes** in the replica set applied a write
- Takes longer than w: 1
- Is more durable than w: 1
  - Useful for ensuring vital writes are majority-commited.

**writeConcern: { w: 0 }**

- Does **not** request an acknowledgement that any nodes applied the write
  - "Fire-and-forget"
- Fastest writeConcern level
- Least durable writeConcern
- For IoT

# Basic Updates

The unit test used in this lesson can be found in the test/lessons/basic_updates.spec.js

The types of update operations in the Node.js driver are:

- .updateOne(): Will update the first document matching the predicate.
- .updateMany(): Will update all the matching documents.

Using the { upsert: true } flag, we can insert a document if the predicate doesn't match any documents in the collection.

# Basic Joins

Are used to combine data from two or more collections.

- Movies and comments

- Use new expressive $lookup
- Build aggregation in Compass, and then export to language.

Expressive lookup allows us to apply aggregation pipelines to data before the data is joined.

Let allows us to declare variables in our pipeline, referring to document fields in our source collection.

Compass 'Export-to-Language' feature produces aggregations in our application's native language.

# Basic Deletes

To follow along with this lesson, read file test/lesson/basic-deletes.spec.js

A delete is basically a write in the database world.

When we perform a delete:

- Collection data will be changed
- Indexes will be updated
- Entries in the oplog will be added

The types of delete operations in the Node.js driver are:

- .deleteOne(): Will delete the first document matching the predicate.
- .deleteMany(): Will delete all the matching documents.

When using .deleteOne(), it is very important that the predicate matches only one document - otherwise, we could accdientally delete the wrong document.
