# FACETS: INTRODUCTION

Many use cases require the ability to Manipulate, Inspect and Anaalyze data across multiple dimensions. Apart from this, these use cases required this data categorization meets strict application as well SLA to enable responsive interfaces.

MongoDB 3.4 -> Introduces support for facet navigation, enabling developers to quickly create an interface that characterizes query results across multiple dimensions or facets. Users can narrow their query results by selecting a facet value as a subsequent filter providing an intuitive interface to exploring a data set.

Facet navigation is heavily used for browsing data catalogs and grouping data in analytics use cases. Combining it with aggregation framework functionality extends MongoDB usage to a wider range of applications with minimun averged.

**What is faceting?**

Is a popular analytics capability that allows users to explore data using multiple filters and characterizations. Using this approach an aplication classifies each information element along multiple explicit dimensions, called facets, enabling  the classifications to be accessed an ordered in multiple ways.

Facets in MongoDB are implemented using the aggregation framework and comprehend a few different stages. Convering: 

- Single Facet Queries
- Manual and Auto Bucketing
- Rendering Multiple Facets.

# FACETS: SINGLE FACET QUERY

```
use startups

db.companies.findOne()

db.compaines.createIndex( { 'description': 'text', 'overview': 'text' })

db.companies.aggregate([
    {
        '$match': {
            '$text': {
                '$search': 'network'
            }
        }
    }
])

db.companies.findOne( {}, {category_code: 1 })

db.companies.aggregate([
    {
        '$match': {
            '$text': {
                '$search': 'network'
            }
        }
    },
    {
        '$sortByCount': '$category_code'
    }
])

db.companies.aggregate([
    {
        '$match': {
            '$text': {
                '$seach': 'network'
            }
        }
    },
    {
        '$unwind': '$offices'
    },
    {
        $match: {
            'offices.city': {
                '$ne': ''
            }
        }
    },
    {
        '$sortByCount': '$offices.city'
    }
])
```

# FACETS: MANUAL BUCKETS

Lets look into bucketing strategies. It is a very common operation associated with facets, where we group data by a range of values, as opposed to individual values. 

We group sorts of documents based on some specific brackets or boundaries where our documents will fit in based on a particular value comprehended on those ranges. 

We might want to bucket companies based on the size of their workforce.

```
db.companies.find({}, {number_of_employees: 1}).sort({ number_of_employees: -1 })

db.companies.aggregate([
    {
        $match: {
            'founded_year': { '$gt'"  1980 }, 'number_of_employees': {'$ne': null}
        }
    },
    {
        '$bucket': {
            'groupBy': '$number_of_employees',
            'boundaries': [ 0,20, 50, 100, 500, 100, Infinity]
        }
    }
])

{ "_id": 0, "count": 5447 } 
{ "_id": 20, "count": 1172 } 
{ "_id": 50, "count": 652 } 
{ "_id": 100, "count": 738 } 
{ "_id": 500, "count": 98 } 
{ "_id": 1000, "count": 137 } 
```

If the data has a data type that does not fit into a bucket will give the error: 

$switch could not find matching branch for an input, and no default was specified

```
db.companies.aggregate([
    {
        $match: {
            'founded_year': { '$gt'"  1980 }
        }
    },
    {
        '$bucket': {
            'groupBy': '$number_of_employees',
            'boundaries': [ 0,20, 50, 100, 500, 100, Infinity],
            'default': 'Other'
        }
    }
])

{ "_id": 0, "count": 5447 } 
{ "_id": 20, "count": 1172 } 
{ "_id": 50, "count": 652 } 
{ "_id": 100, "count": 738 } 
{ "_id": 500, "count": 98 } 
{ "_id": 1000, "count": 137 } 
{ "_id": "Other", "count": 4522 } 
```

The boundaries array can only contain values of the same datatype.

The $bucket stage let us set our output field: 

```
db.companies.aggregate([
    {
        $match: {
            'founded_year': { '$gt'"  1980 }
        }
    },
    {
        '$bucket': {
            'groupBy': '$number_of_employees',
            'boundaries': [ 0,20, 50, 100, 500, 100, Infinity],
            'default': 'Other',
            'output': {
                'total': { '$sum': 1 },
                'average': { '$avg': '$number_of_employees' },
                'categories': { '$addToSet': '$category_code' }
            }
        }
    }
])
```

# FACETS: AUTO BUCKETS

MongoDB 3.4 we habe $bucketAuto. Is another aggregation framework stage.

$bucketAuto tries to balance the documents that will be distributed in the buckets it creates.

```
db.companies.aggregate([
    {
        '$match': {
            'offices.city': 'New York'
        }
    },
    {
        '$bucketAuto': {
            'groupBy': '$founded_year',
            'buckets': 5 # How many buckets
        }
    }
])
```

We can also define our output fields:

```
db.companies.aggregate([
    {
        '$match': {
            'offices.city': 'New York'
        }
    },
    {
        '$bucketAuto': {
            'groupBy': '$founded_year',
            'buckets': 5,
            'output': {
                'total': { '$sum': 1 },
                'average': { '$avg': '$number_of_employees' }
            }
        }
    }
])
```

$bucketAuto accepts an optional granularity parameter which ensures that the boundaries af all buckets adhere to a specified preferred number series (Renard Series, E Series, 1-2-5 Series, Powers of 2 Series)

```
for (i=1; i <= 1000; i++) { db.series.inser( { _id: i } ) }

db.series.aggregate ([
    {
        $bucketAuto: {
            groupBy: '$_id', 
            buckets: 5
        }
    }
])

# Renard Series 20

db.series.aggregate ([
    {
        $bucketAuto: {
            groupBy: '$_id', 
            buckets: 5,
            granularity: 'R20'
        }
    }
])
```

# MULTIPLE FACETS

When building applications, we might need multiple different facets to achieve the kind of filters that we want to provide to our end user.

Faceting support can compute several different facets in a single command so we can avoid making to many round trips to the database.

To do this we have a new operator called $facet. It allows us to do exactly that. Lets take all the individual facets we have been building a group them in a facet.

```
db.companies.aggregate ([
    {
        '$match': { 
            '$text': { 
                '$search': 'Databases'
                }
        }
    },
    {
        $facet: {
            'Categories': [ 
                {
                    '$sortByCount': '$category_code'
                }
            ],
            'Employees': [
                {
                    '$match': {
                        'founded_year': {
                            '$gt': 1980
                        }
                    }
                },
                {
                    $bucket: {
                        'groupBy': '$number_of_employees',
                        'boundaries': [
                            0,
                            20,
                            50,
                            100,
                            500,
                            100,
                            Infinity
                        ],
                        'default': 'Other'
                    }
                }
            ],
            'Founded': [
                {
                    '$match': { 'offices.city': 'New York' }
                },
                {
                    '$bucketAuto': {
                        'groupBy': '$founded_year',
                        'bukets': 5
                    }
                }
            ]
        }
    }
])
```

Each sub-pipeline within facet is past the exact same set of input documents that the match stage generates and they are independent from one another. 

The output of one sub-pipeline cannot be used by the following ones within the same facet command.

# LAB

```
db.movies.findOne({ title: 'Life Is Beautiful'})

db.movies.aggregate ([
    {
        $project: {
            _id: 0,
            title: 1,
            imdb: 1,
            metacritic: 1
        }
    },
    {
        $sort: {
            metacritic: -1
        }
    },
    {
        $project: {
            title: 1
        }
    },
    {
        $limit: 10
    }
])


db.movies.aggregate ([
    {
        $match: {
            'imdb.rating': { $gt: 0}
        }
    },
    {
        $project: {
            _id: 0,
            title: 1,
            imdb: 1,
            metacritic: 1
        }
    },
    {
        $sort: {
            'imdb.rating': -1
        }
    },
    {
        $project: {
            title: 1,
            'imdb.rating': 1
        }
    },
    {
        $limit: 10
    }
])
```

{ "title" : "The Wizard of Oz" }
{ "title" : "Au Hasard Balthazar" }
{ "title" : "The Godfather" }
{ "title" : "Lawrence of Arabia" }
{ "title" : "Journey to Italy" }
{ "title" : "The Conformist" }
{ "title" : "Boyhood" }
{ "title" : "Fanny and Alexander" }
{ "title" : "The Leopard" }
{ "title" : "Sweet Smell of Success" }

{ "title" : "Band of Brothers" }
{ "title" : "Dances Sacred and Profane" }
{ "title" : "The Third Annual 'On Cinema' Oscar Special" }
{ "title" : "Planet Earth" }
{ "title" : "The Chaos Class" }
{ "title" : "A Brave Heart: The Lizzie Velasquez Story" }
{ "title" : "Thani Oruvan" }
{ "title" : "Drag Becomes Him" }
{ "title" : "The Civil War" }
{ "title" : "The Shawshank Redemption" }

# THE $sortByCount STAGE:

Takes one argument, an expression to group documents on.  It works just like a grup stage, followed by a sort in descending direction.

```
db.movies.aggregate([
    {
        $group: {
            _id: "$imdb.rating",
            count: { $sum: 1 }
        }
    },
    {
        $sort: { count: -1 }
    }
])

# Vs

db.movies.aggregate([
    {
        $sortByCount: "$imdb.rating"
    }
])
```

# SUMMARY

**$bucket**
- Must always specify at least 2 values to boundaries.
- boundaries must all be of the same general type (Numeric, String)
- count is inserted by default with no output, but removed when output is specified.

**$bucketAuto**
- Cardinality of groupBy expressions may impact even distribution and number of buckets.
- Specifying a granularity requires the expression to groupBy to resolve to a numeric value

**$sortByCount**
- Is equivalent to a group stage to count occurrence, and then sorting in descending order.