# THE $redact STAGE

This stage can help us protect information from unauthorized access.

```
{
    $redact: 'expression'
}
```

**$$DESCEND - Retain this level**

Retains the field at the current document level been evaluated except for subdocuments and arrays of documents. It will instead traverse down, evaluating each level. 

```
{ 
    $cond: [ { $in: [ "Management", "$acl" ]}, "$$DESCEND", "$$PRUNE" ]
}
    {
        acl: [ "HR", "Management", "Finance", "Executive"],
        employee_compensation: {
            acl: [ "Management", "Finance", "Executive"],
            ...
            programs: {
                acl: [ "Finance", "Executive" ],
                ...
            }
        }   
    }

var userAccess = "Management"

db.employees.aggregate([
    {
        $redact: { $cond: [{ $in: [ userAccess, "$acl" ]}, "$$DESCEND", "$$PRUNE" ] }
    }
]).pretty()
```

**$$PRUNE - Remove**

Will exclude all fields at the current document level without further inspection.

**$$KEEP - Retain**

Will retain all fields at the current document level without further inspection. 

**Summary**

The $redact stage can be usefull when implementing acl lists but it is not the only way to limit access to information. When we are evaluating certain field, that field must exist in every level.

- $$KEEP and $$PRUNE automatically apply to all levels below the evaluated level.
- $$DESCEND retains the current level and evaluates the next level down.
- $redact is not for restricting access to a collection. If the user can performa an aggregation on a collection, the user has access to read that collection.

# THE $out STAGE

A useful stage for persisting the results of an aggregation. $out stage has the following form:

```
{ $out: "output_collection" }
```

The $out stage must be the last stage in the pipeline:

```
db.collection.aggregate([
    { $stage1 }, { $stage2 }, ..., { $stageN }, { $out: "new_collection" } 
])
```

No use within $facet!

MongoDB will create the collection with the name specified if none exists. Otherwise it will overwrite an existing collection if an existing collection name is specified. (Must honor existing indexes if specifying an existing collection!)

It will only create collections within the same database. If there are pipeline errors it will not create or overwrite collections. 

**Summary**

- Will create a new collection or overwrite an existing collection if specified.
- Honors indexes on existing collections.
- Will not create or overwrite data if pipeline errors.
- Creates collections in the same database as the source collection.

# $merge OVERVIEW

The only way of saving the aggregation pipeline prior to MongoDB 4.2, was by writing it to a new, unsharded collection, via the $out stage. If the collection you wanted to write already existed, $out would replace it with the new version and it couldn't be sharded.

$merge allows flexible ways of saving results of the aggregation into an already existing collection whether it's sharded or unsharded.

```
db.coll.aggregate([
    { pipeline}, ...
    { $merge: { ... }}
])
```

$merge can output to any existing collection, whether it's sharded or unsharded. You can output to a collection in a different database. And you can specify exactly how you want the new documents from this aggregation to be merged into the existing collection.

Let's look at $merge syntax now.

```
{
    $merge: {
        into: 'target: required.'
    }
}

{ $merge: "collection2" }

{ $merge: { db: "db2", coll: "collection2" }}

{
    $merge: {
        into: 'target',
        on: 'fields - optional - if not specified _id is used, must be unique'
    }
}
```

# $merge SYNTAX

```
{
    $merge: {
        into: 'target',
        on: 'fields'
    }
}
```

**Actions**

- Nothing matched: Usually insert the new document.
- Document matched: Overwrite? Update?

```
# The default option is like an upsert 
{
    $merge: {
        into: 'target',
        whenNotMatched: "insert",
        whenMatched: "merge"
    }
}


{
    $merge: {
        into: 'target',
        whenNotMatched: "insert " | "discard" | "fail",
        whenMatched: "merge" | "replace" | "keepExisting" | "fail" | [... You can specify your own custom pipeline ]
    }
}

{
    $merge: {
        into: 'target',
        whenMatched: [
            { $addFields: {
                total: { $sum: [ "$total", "$$new.total"]}
            }}
        ]
    }
}

{
    $merge: {
        into: 'target',
        whenMatched: [
            { $set: {
                total: { $sum: [ "$total", "$$new.total"]}
            }}
        ]
    }
}

{
    $merge: {
        into: 'target',
        whenMatched: [
            { $replaceWith: {
                $mergeObjects: [
                    "$$new",
                    { total: { 
                        $sum: ["$$new.total", "$total"]
                    }}
                ]
            }}
        ]
    }
}

# Let lets you define a variable from the incoming data.

{
    $merge: {
        into: 'target',
        let: { itotal: "$total"},
        whenMatched: [

        ]
    }
}
```
# USING $merge FOR SINGLE VIEW

Using $merge to populate/update user fields from other services.

$merge updates fields from mflix.users collection into sv.users collection. Our "_id" field is unique username.

```
use mflix

db.users.aggregate([
    {
        $project: {
            _id: "$username",
            mflix: "$$ROOT"
        }
    },
    {
        $merge: {
            into: { db: "sv", collection: "users" },
            whenNotMatched: "discard"
        }
    }
])
```

$merge updates fields from mfriendbook.users collection into sv.users collection. Our "_id" field is unique username

```
use mfriendbook

db.users.aggregate([
    {
        $project: {
            _id: "$username",
            mfriendbook: "$$ROOT"
        }
    },
    {
        $merge: {
            into: { db: "sv", collection: "users" },
            whenNotMatched: "discard"
        }
    }
])
```
# USING $merge FOR TEMPORARY COLLECTION

Append from a Temporary collection into some permanent collection.

Using $merge to append loaded and cleansed records loaded into db.

```
db.temp.aggregate([
    {...} /*pipeline to massage and cleanse data in temp */,
    {
        $merge: {
            into: "data",
            whenMatched: "fail"
        }
    }
])
```

Similar to sql insert into t1 select * from t2

# USING $merge FOR RULLUPS

Populate rollups in summary table. Using $merge to incrementally update periodic rollups in summary.

Table of registrations ---> Table of Registration summary

$merge to create/update periodic rollups in summary collection (for all days)

```
db.regsummary.createIndex({event: 1, date: 1}, { unique: true});

db.registrations.aggregate([
    {
        $match: { event_id: "MDBW19"}
    },
    {
        $group: {
            _id: { $dateToString: { date: "$date", format: "%Y-%m-%d}},
            count: {$sum: 1}
        }
    },
    {
        $project: { _id: 0, event: "MDBW19", date: "$_id", total: "$count" }
    },
    {
        $merge: {
            into: "regsumary";
            on: [ "event", "date" ]
        }
    }
])
```

$merge to incrementally update periodic rollups in summary collection (for single day)

```
db.registrations.aggregate([
    {
        $match: { 
            event_id: "MDBW19",
            date: {
                $gte: ISODate("2019-05-22"), $lt: ISODate("2019-05-23")
            }
        }
    },
    {
        $count: "total"
    },
    {
        $addFields: {
            event: "MDBW19",
            "date": "2019-05-22"
        }   
    },
    {
        $merge: {
            into: "regsumary";
            on: [ "event", "date" ]
        }
    }
])
```
# VIEWS

MongodB enables non-materialized views, meaning they are computed every time a rate operation is performed against that view. They are a way to use an aggregation pipeline as a collection.

From the user perspective, views are perceived as collections. Views allow us to create vertical and horizontal slices of our collection.

Vertical slicing is performed through the use of a project stage, and other similar stages that change the shape of the documents being returned. Vertical slices change the shape being returned but not the number of documents being returned.

```
db.customers.aggregate([
    {
        $project: { _id: 0, accountType: 1}
    }
])
```

Horizontal slicing is performed through the use of match stages. We select only a subset of documents based on some criteria. Horizontal slices change the number of documents returned but not the shape.

```
db.customers.aggregate([
    {
        $match: { accountType: "bronze" }
    }
])
```

Creating a view that perform both horizontal and vertical slicing.

Syntax:

```
db.createView("view_name", "origin_collection", "pipeline" )
```

Example
```
db.createView("bronze_banking", "customers", [
    {
        $match: { accountType: "bronze" }
    },
    {
        $project: {
            _id: 0,
            name: {
                $concat: [
                    { $cond. [ { $eq: [ "$gender", "female" ] }, "Miss", "Mr."]},
                    " ", "$name.first", " ", "$name.last"
                ]
            },
            phone: 1,
            email: 1,
            address: 1,
            account_ending: { $substr: [ "$accountNumber", 7, -1 ]}
        }
    }
])
```

Views can be created in two different ways. We have the shell helper method, db.createView, and the createCollection method.

```
db.createView('view', 'source', 'pipeline', 'collation')

db.createCollection('name', 'options')
```

New meta information to include the pipeline that computes the view, is stored in the system.views collection. The only information stored about a view is the name, the source collection, the pipeline that defines it and optionally the collation.

```
db.system.views.find().pretty()
```

All collection read operations are available as views.

```
db.view.find()

db.view.findOne()

db.view.count()

db.view.distinct()

db.view.aggregate() (so meta)
```

Vies do have some restrictions:
- No write operations
- No index operations (create, update)
- No renaming
- No mapReduce
- No $text
- No geoNear or $geoNear
- Collation restrictions
- find() operations with projection operators are not permited
    - $
    - $elemMatch
    - $slice
    - $meta
- Views definitions are public. Any role that can list collections on a database can see a view definition as we saw earlier.
- Avoid referring to sensitive fields within the pipeline that defines a view.

**Summary**

- Views contain no data themselves. They are created on demand and reflect the data in the source collection.
- Views are read only. Write operation to views will error.
- Views have some restrictions. They musto abide by the rules of the Aggregation Framework, and cannot contain find() projection operators.
- Horizontal slicing is performed with the $match stage, reducing the number of documents that are returned.
- Vertical slicing is performed with a $project or other shaping stage, modifying individual documents.