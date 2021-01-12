# THE $group STAGE

Key to our comprehension of group is to understand the one required argument: the _id field of this stage.

The expression or expressions we specify to _id becomes the criteria the group stage uses to categorize and bundle documents together.

Grouping documents in our movies collection based on the value in their year field:

```
db.movies.aggregate([
    {
        $group: { _id: "$year" }
    }
])
```

By itself, this may or may not be useful depending on the use case, and just grouping on one expression si functionally equivalent to using the distinct command.

Here we are gouing to group on the value of year, and also calculate a new field called num_films_in_year using $sum:

```
db.movies.aggregate([
    {
        $group: {
            _id: "$year",
            num_films_in_year: { $sum: 1 }
        }
    }
])
```

```
db.movies.aggregate([
    {
        $group: {
            _id: {
                numDirectors: { 
                    $cond: [ { $isArray: "$directors" }, { $size: "$directors"}, 0]}
            },
            numFilms: { $sum: 1 },
            averageMetacritic: { $avg: "$metacritic" }
        }
    },
    {
        $sort: { 
            "_id.numDirectors": -1 
        }
    }
])

db.movies.findOne({ directors: { $size: 44} })
```

**Summary**

- _id is where to specify what incoming documents should be grouped on
- Can use all accumulator expressions within $group
- $group can be used multiple times within a pipeline
- It may be necessary to sanitize incoming data

# ACCUMULATOR STAGES WITH $project

Lets learn about using acumulator expressions with the $project stage. Knowledge of how to use this expressions can simplify our work.

Accumulator Expressions in $project operate over an array in the current document, thy do not carry values over all documents!

$reduce takes an array as input argument. The initialValues is -Infinity because any temperature we find will be greater than -Infinity. Lastly we have to specify the logic in the in field.

```
db.icecream_data.aggregate([
    {
        $project: {
            _id: 0,
            max_high: {
                $reduce: {
                    input: "$trends",
                    initialValue: -Infinity,
                    in: {
                        $cond: [
                            {$gt: ["$$this.avg_high_tmp", "$$value"]},
                            "$$this.avg_high_tmp",
                            "$$value"
                        ]
                    }
                }
            }
        }
    }
])
```

This is easier using the $max accumulator:

```
db.icecream_data.aggregate([
    {
        $project: {
            _id: 0,
            max_high: {
                $max: "$trends.avg_high_tmp"
            }
        }
    }
])
```

With the $min we get the minimun temperature.

```
db.icecream_data.aggregate([
    {
        $project: {
            _id: 0,
            max_low: {
                $min: "$trends.avg_low_tmp"
            }
        }
    }
])
```

We can also calculate averages and standard deviations using $avg and $stdDevPop (Population Standard Deviation because we are using all our data i we used a sample we should use a Sample Standard Deviation)

```
db.icecream_data.aggregate([
    {
        $project: {
            _id: 0,
            average_cpi: {
                $avg: "$trends.icecream_cpi"
            },
            cpi_deviation: {
                $stdDevPop: "$trends.icecream_cpi"
            }
        }
    }
])
```

$sum sums the values of an array:

```
db.icecream_data.aggregate([
    {
        $project: {
            _id: 0,
            "yearly_sales (millions)": {
                $sum: "$trends.icecream_sales_in_millions"
            }
        }
    }
])
```

**Things to keep in mind**

- Available Accumulatro Expressions
    - $sum, $avg, $max, $min, $stdDevPop, $stdDevsam
- Expressions have no memory between documents
- May still have to use $reduce o $map for more complex calculations.

# LAB

```
db.movies.findOne({ title: "Life Is Beautiful" })

db.movies.find({ awards: { $regex: /^Won .* Oscar*/}}, { awards: 1 }).itcount()

db.movies.find({ awards: { $regex: /^Won .*/}}, { awards: 1}).itcount()

db.movies.aggregate([
    {
        $match: {
            awards: { $regex: /^Won .* Oscar*/ }
        }
    },
    {
        $project: {
            _id: 0,
            imdb: 1,
            won: "true"
        }
    },
    {
        $group: {
            _id: "$won",
            highest_rating: { $max: "$imdb.rating" },
            lowest_rating: { $min: "$imdb.rating" },
            average_rating: { $avg: "$imdb.rating" },
            deviation: { $stdDevPop:"$imdb.rating" }
        }
    }
])
```

# THE $unwind STAGE

Let us unwind an array field creating a new document for every entry where the field value is a new entry.

```
{
    "title": "The Martian",
    "genre": [ "Action", "Adventure", "Sci-Fi"]
}
```

if $unwind: "$genre" then

```
{
    "title": "The Martian",
    "genre": "Action"
}
{
    "title": "The Martian",
    "genre": "Adventure"    
}
{
    "title": "The Martian",
    "genre": "Sci-Fi"
}
```

Useful if we would like to group on individual entries. Because [ "Adventure", "Action" ] != [ "Action", "Adventure" ]

**Short Form**

$unwind: `<field path>`

**Long Form**

$unwind: {
    path: `<field path>`,
    includeArrayIndex: `<string>`,
    preserveNullAndEmptyArrays: `<boolean>`
} 

**Highlights**

- $unwind only works on array values
- There are two forms for unwind, short form and long form
- Using unwind on large collections with big documents may lead to performance issues.

# LAB

```
mongo "mongodb://cluster0-shard-00-00-jxeqq.mongodb.net:27017,cluster0-shard-00-01-jxeqq.mongodb.net:27017,cluster0-shard-00-02-jxeqq.mongodb.net:27017/aggregations?replicaSet=Cluster0-shard-0" --authenticationDatabase admin --ssl -u m121 -p aggregations --norc


db.movies.findOne({ title: "Life Is Beautiful" })

db.movies.aggregate([
    {
        $match: {
            languages: { $in: ["English"]} 
        }
    },
    {
        $project: {
            _id: 0,
            title: 1,
            cast: 1,
            imdbRating: "$imdb.rating",
        }
    }, 
    {
        $unwind: "$cast"
    },
    {
        $group: {
            _id: "$cast",
            numFilms: { $sum: 1 },
            averagex: { $avg: "$imdbRating" }
        }
    },
    {
        $project: {
            _id: 1,
            numFilms: 1,
            average: { $trunc: [ "$averagex", 1 ]}
        }
    },
    {
        $sort: { numFilms: -1 }
    }
])

{ "_id" : "John Wayne", "numFilms" : 107, "average" : 6.4 }
```

# THE $lookup STAGE

A powerfull stage that lets you combine information from two collections. $lookup is efectively a left outer join. (Combines all documents from the left with matching documents on the right.)

The $lookup stage has this form:

```
$lookup: {
    from: 'collection to join',
    localField: 'field from the input documents',
    foreignField: 'field from the documents of the "from" collection',
    as: 'output array field'
}
```

from: Can't be sharded and must exist within the same database.

**Summary**

- The **from** collection cannot be sharded.
- The **from** collection must be in the same database
- The values in **localField** and **foreignField** are matched on equality
- **as** can be any Name, but if it exists in the working document that field will be overwritten.

# LAB

```
mongo "mongodb://cluster0-shard-00-00-jxeqq.mongodb.net:27017,cluster0-shard-00-01-jxeqq.mongodb.net:27017,cluster0-shard-00-02-jxeqq.mongodb.net:27017/aggregations?replicaSet=Cluster0-shard-0" --authenticationDatabase admin --ssl -u m121 -p aggregations --norc

db.air_alliances.findOne()

db.air_routes.findOne({ airplane: "380"})

db.air_alliances.aggregate([
    {
        $lookup: {
            from: "air_routes",
            localField: "airlines",
            foreignField: "airline.name",
            as: "routes"
        }
    },
    {
        $project: {
            _id: 0,
            name: 1,
            routePlane: { $split: [
                {
                    $reduce: {
                        input: "$routes.airplane",
                        initialValue: "",
                        in: { $concat: [ "$$value", " ", "$$this" ]}
                    }
                }, " "
            ]}
        }
    },
    {
        $project: {
            name: 1,
            num_routes: {
                $reduce: {
                    input: "$routePlane",
                    initialValue: 0,
                    in: { $add: ["$$value", {
                        $cond: {
                            if: {
                                $in: [ "$$this", [ "747", "380"]]
                            },
                            then: 1,
                            else: 0
                        }
                    }] }
                }
            }
        }
    },
    {
        $sort: { num_routes: -1}
    },
    {
        $limit: 1
    }
]).pretty()
```

# $graphLookup Introduction

Mongodb offers a flexible data model document can be of different shapes and forms and organized in a way that reflects both application dynamic data structurs and scalability requirements. We can have very flat root level only fields or quite complex and deeply nested schemas that reflect application needs for fast operations and business logic.

A common set of data structures that require both complex nesting levels and flexible storage layer tends to be graph or tree hierarchy use cases. Data sets can be as simple as a reporting chain HR data store or complex data structures that map airport raveling routes or even social networks.

Telcos switch, desease taxonomy, and fraud detection are amongst several differente use cases where graph queryability and flexible data representation go hand in hand.

Unlike graph specific databases, MongoDB is designed to be a generar purpose database, meaning very good infrastructure to support operational and analytical use cases.

Graph lookup allows developers to combine their flexible data sets with graph or graph-like operations. This enables all of those complex data sets to be processed, analyzed, and transformed using a single data source.

When designing and implementing graph relationships and designing its queries, we generally need to think about transitive relationships. If A reports to B, and B reports to C, then A indirectly reports to C. In standard SQL, such hierarchical queries are implemented by way of recursive common table expressions. In relational DBs this is called transitive closure.

Graph lookup allows looking up recursively a set of documents witha a defined relationship to a starting document. Graph lookup is very similar to our $lookup operation but with a few important variations.

```
$graphLookup: {
    from: 'lookup table',
    startsWith: 'expression for value to start from',
    connectFromField: 'field name to connect from',
    connectToField: 'field name to connect to',
    as: 'fiel name for result array',
    maxDepth: 'optional, number of iterations to perform',
    depthField: 'fiel name for number of iterations to reach this node',
    restrictSearchWithMatch: 'match condition to apply to lookup'
}
```

- **from**: Specifies a collection at this stage retrieves result from.
- **startsWith**: Specifies the connect to field value or values that we should start our recrusive search wit.
- **connectFromField**: Determines a field in each document in the form collection that is used to perform the next recursive query.
- **connectToField**: Sets the field in each document in the from collection that is queried against each recursive query.
- **as**: Specifies a field in the output document that will be assigned an array of results of the graph lookup.
- **maxDepth**: Optional, Specifies the maximun number of recursive depth for the graph lookup.
- **depthField**: Optional, Specifies in field name in which the result document will be set to the recursive depth a chich the document was retrieved, zero for the first lookup. 
- **restrictsearchWithMatch**: optional, Specifies a filter to apply when doing the lookup in the form collection.

# $graphLookup: simple Lookup

while modeling tree structures, there are different patterns that we can follow depending on how we want to juggle wit our data.

Lets have a look to an organizational chart... Modeling sucha tree in a document or structure of documents.

**Parent Reference**

Each single document will have a particular attribute field that indicate us who we report to (Our parent in the tree structure.)

```
{ "_id": 4, "name": "Carlos", "title": "CRO", "reports_to": 1}
{ "_id": 1, "name": "Dev", "title": "CEO" }
```

With this schema its quite easy to navigate between differente documents.

```
db.parent_reference.find( { 'name': 'Dev' })

db.parent_reference.find( { 'reports_to': 1 })

db.parent_reference.find( { 'reports_to': 2 })
```

This is very inefficient, alternatively we can use $graphLookup:

```
db.parent_reference.aggregate([
    {
        $match: {
            name: 'Eliot'
        }
    },
    {
        $graphLookup: {
            from: 'parent_reference',
            startWith: '$_id',
            connectFromField: '_id',
            connectToField: 'reports_to',
            as: 'all_reports'
        }
    }
]).pretty()
```

We can do it in reverse:

```
db.parent_reference.aggregate([
    {
        $match: {
            name: 'Shannon'
        }
    },
    {
        $graphLookup: {
            from: 'parent_reference',
            startWith: '$reports_to',
            connectFromField: 'reports_to',
            connectToField: '_id',
            as: 'bosses'
        }
    }
]).pretty()
```

# $graphLookup: Simple Lookup Reverse Schema

Another pattern that we can apply wil be to have the reverse referencing. To do this, we need to transform our documents. Instead of having a reference back to its parents, what we're going to have is each single document referencing its direct reports.

```
db.child_reference.findOne( { name: 'Dev' })

{
    "_id": 1,
    "name": "Dev",
    "title": "CEO",
    "direct_reports": {
        "Eliot",
        "Meagen",
        "Carlos",
        "Richard",
        "Kirsten"
    }
}

db.child_reference.aggregate([
    { $match: { name: 'Dev' }},
    { $graphLookup: {
        from: 'child_reference',
        startWith: '$direct_reports',
        connectFromField: 'direct_reports',
        connectToField: 'name',
        as: 'all_reports'
    }}
]).pretty()
```

# $graphLookup: maxDepth and depthField

In some situations, we might not be interested on the full list.

A single lookup is depth zero. Two levels down, is depth 1.

```
db.child_reference.aggregate([
    { $match: { name: 'Dev' }},
    { $graphLookup: {
        from: 'child_reference',
        startWith: '$direct_reports',
        connectFromField: 'direct_reports',
        connectToField: 'name',
        as: 'till_2_level_reports',
        maxDepth: 1
    }}
]).pretty()
```

So basically, maxDepth will restrict how many times we want to recursively find documents that match or they are connected using the connectFromField and the connectToField.

If i also want to know how far are those elements from the first element.

```
db.child_reference.aggregate([
    { $match: { name: 'Dev' }},
    { $graphLookup: {
        from: 'child_reference',
        startWith: '$direct_reports',
        connectFromField: 'direct_reports',
        connectToField: 'name',
        as: 'descendants',
        maxDepth: 1,
        depthField: 'level'
    }}
]).pretty()
```

By specifying depthField i can get the information of how many recursive lookups where needed to find that particular element on our descendants field here.

# $graphLookup: CROSS COLLECTION LOOKUP

So far we've been analyzing graph lookup on self lookups. As in any other ordinary lookup, we can start from one initial collection and lookup another collections.

```
show collections

db.air_airlines.findOne()

db.air_routes.findOne()

db.air_airlines.aggregate([
    {
        $match: { name: "TAP Portugal"}
    },
    {
        $graphLookup: {
            from: 'air_routes',
            as: 'chain',
            startWith: '$base',
            connectFromField: 'dst_airport',
            connectToField: 'src_airport',
            maxDepth: 1
        }
    }
]).pretty()


db.air_airlines.aggregate([
    {
        $match: { name: "TAP Portugal"}
    },
    {
        $graphLookup: {
            from: 'air_routes',
            as: 'chain',
            startWith: '$base',
            connectFromField: 'dst_airport',
            connectToField: 'src_airport',
            maxDepth: 1,
            restrictSearchWithMatch: {
                "airline.name": "TAP Portugal"
            }
        }
    }
]).pretty()
```

# $graphLookup: GENERAL CONSIDERATIONS

**Memory allocation**

Due to its recursive nature it may require a significate amount of memory to work properly. So allowDiskUse will be your friend.

Another important thing to keep in mind is the use of indexes. Indexes will accelerate or might accelerate our queries. Having our connectToField indexed will be a good thing.

Our from collection can't be sharded.

Also, unrelated match stages do not get pushed before graph lookup in the pipeline. Threfore, will not be optimized if they are not related with the $graphLookup operator.

Giving its recursive nature, $graphLookup may exceede its allowed memory usage without spilling to disk. Even using allowDiskUse it may exceed the 100Mb allowed.

# LAB

Option 1: ?

```
db.air_alliances.aggregate([
    {
        $match: { name: "OneWorld" }
    },
    {
        $graphLookup: {
            startWith: "$airlines",
            from: "air_airlines",
            connectFromField: "name",
            connectToField: "name",
            as: "airlines",
            maxDepth: 0,
            restrictSearchWithMatch: {
                country: { $in: [ "Germany", "Spain", "Canada" ]}
            }
        }
    },
    {
        $graphLookup: {
            startWith: "$airlines.base",
            from: "air_routes",
            connectFromField: "dst_airport",
            connectToField: "src_airport",
            as: "connections",
            maxDepth: 1
        }
    },
    {
        $project: {
            validAirlines: "$airlines.name",
            "connections.dst_airport": 1,
            "connections.airline.name": 1
        }
    },
    { $unwind: "$connections" },
    {
        $project: {
            isValid: { $in: [ "$connections.airline.name", "$validAirlines"]},
            "connections.dst_airport": 1
        }
    },
    { $match: { isValid: true }},
    { $group: { _id: "$connections.dst_airport" }}
]).itcount()
```

Option 2: X

```
db.air_airlines.aggregate([
    {
        $match: {
            country: { $in: ["Spain", "Germany", "Canada" ]}
        }
    },
    {
        $lookup: {
            from: "air_alliances",
            foreignField: "airlines",
            localField: "name",
            as: "alliance"
        }
    },
    { 
        $match: {
            "alliance.name": "OneWorld"
        }
    },
    { 
        $graphLookup: {
            startWith: "$base",
            from: "air_routes",
            connectFromField: "dst_airport",
            connectToField: "src_airport",
            as: "connections",
            maxDepth: 1
        }
    },
    {
        $project: {
            "connections.dst_airport": 1
        }
    },
    {
        $unwind: "$connections"
    },
    {
        $group: {
            _id: "$connections.dst_airport"
        }
    }
]).itcount()
```

Option 3: X

```
db.air_routes.aggregate([
    {
        $lookup: {
            from: "air_alliances",
            foreignField: "airlines",
            localField: "airline.name",
            as: "alliance"
        }
    },
    {
        $match: {
            "alliance.name": "OneWorld"
        }
    },
    {
        $lookup: {
            from: "air_airlines",
            foreignField: "name",
            localField: "airline.name",
            as: "airline"
        }
    },
    {
        $graphLookup: {
            startWith: "$airline.base",
            from: "air_routes",
            connectFromField: "dst_airport",
            connectToField: "src_airport",
            as: "connections",
            maxDepth: 1
        }
    },
    { 
        $project: {
            "connections.dst_airport": 1
        }
    },
    {
        $unwind: "$connections"
    },
    {
        $group: {
            _id: "$connections.dst_airport"
        }
    }
]).itcount()
```
Option 4: X

```
var airlines = [];
db.air_alliances.find({ "name": "OneWorld"}).forEach(
    function(doc){
        airlines = doc.airlines
    }
)
var oneWorldAirlines = db.air_airlines.find({ "name": { "$in": airlines }})

oneWorldAirlines.forEach(
    function(airline){
        db.air_alliances.aggregate([
            {
                "$graphLookup": {
                    "startWith": airline.base,
                    "from": "air_routes",
                    "connectFromField": "dst_airport",
                    "connectToField": "src_airport",
                    "as": "connections",
                    "maxDepth": 1
                }
            }
        ]).itcount()
    }
)
```