# FILTERING DOCUMENTS WITH $match

One of the more important stages. Is vital to a successful and performant pipeline. It should come as early as posible and you can use as many match stages as necesary.

Basic Syntax of $match:

```
db.solarSystem.aggregate([{
    $match: {}
}])
```

$match can be used multiple times and virtually any other stage can follow it with few exceptions. Think of $match as a filter rather than a find.

$match uses standard MongoDB query operators! But cant use $word operator and if we want to use $text operator the $match should be the first stage of our pipeline. If match is the first stage it can make use of indexes that is why it should apear early in our pipelines.

Example:

> db.solarSystem.aggregate([{ $match: {  type: { $ne: "Star" } } } ]).pretty()
>
> db.solarSystem.find( { type: { $ne: "Star" } }).pretty()
> 
> db.solarSystem.count( { type: { $ne: "Star" } })
> 
> db.solarSystem.aggregate([{ $match: { type: { $ne: "Star" } } }, { $count: "planets" }])

$match does not allow for projection.

Key Things to Remember:
- A $match stage may contain a $text query operator, but it must be the first stage in a pipeline.
- $match shoul come early in an aggregation pipeline.
- You cannot use $where with $match
- $match uses the same query syntax as find

## LAB

> mongo "mongodb://cluster0-shard-00-00-jxeqq.mongodb.net:27017,cluster0-shard-00-01-jxeqq.mongodb.net:27017,cluster0-shard-00-02-jxeqq.mongodb.net:27017/aggregations?replicaSet=Cluster0-shard-0" --authenticationDatabase admin --ssl -u m121 -p aggregations --norc
>
> db
>
> show collections
>
> db.movies.findOne()

```
var pipeline = [{ $match: { "imdb.rating": { $gte: 7 }, genres: { $nin: ["Crime", "Horror"]}, rated: { $in: ["G", "PG"]}, languages: { $all: ["English", "Japanese"]}}}]

db.movies.aggregate([{ 
    $match: { 
        "imdb.rating": { $gte: 7 },
        genres: { $nin: ["Crime", "Horror"]},
        rated: { $in: ["G", "PG"]},
        languages: { $all: ["English", "Japanese"]}
        }
}]).itcount()

load('validateLab1.js')

validateLab1(pipeline)
```

# SHAPING DOCUMENTS WITH $project

Like match is a vital stage to understand and be successful with the aggregation framework. Pleas dont think of project as the projection functionality that comes with find. It can do much more. We can selectively remove and retain fields, we can reasign existing field values and derive entire new fields.

If match is like a filter method, project is like map.

Basic Syntax for $project

```
db.solarSystem.aggregate([{ $project: {...} }])

# This means we want to remove _id and retain the name field...

db.solarSystem.aggregate([{
    $project: { _id: 0, name: 1 }
}])

# This will also give me the _id field to because you have to explicitly remove it

db.solarSystem.aggregate([{
    $project: { name: 1, gravity: 1 }
}])

# Note gravity.value goes inside quotes...

db.solarSystem.aggregate([{
    $project: { name: 1, "gravity.value": 1 }
}])

# Assigning gravity.value to gravity field...

db.solarSystem.aggregate([{
    $project: { name: 1, gravity: "$gravity.value" }
}])

# Creating a new value named surfaceGravity

db.solarSystem.aggregate([{
    $project: { name: 1, surfaceGravity: "$gravity.value" }
}])
```
We can use expresions like multiply, multiply takes an array of values an multiplies them 

```
{ $multiply: [ gravityRatio, weightOnEarth ] }
```

We can use divide, that takes an array of two values and divide the first by the second.

```
{ $divide: [ "$gravity.value", gravityOnEarth ]}
```

Puting it all together we have the following:

```
db.solarSystem.aggregate([{
    $project: {
        _id: 0,
        name: 1,
        myWeight: { $multiply: [ { $divide: [ "$gravity.value", 9.8 ] }, 86 ] }
    }
}])
```

**Things to Remember**

- Project is a powerfull state of the aggregation framework, we can remove, retain, derive an generate fields.
- It can be used any number of times in a pipeline and we should use it aggresively to remove data that is not necessary so we keep our pipelines performant.
- Once we specify one field to retain, we must specify all fields we want to retain. The _id field is the only exception to this.
- Beyond simply removing and retaining fields, $project lets us add new fields.
- $project can be used as many times as required within an Aggregation pipeline.
- $project can be used to reassign values to existing field names and to derive entirely new fields.

# LAB

```
var pipeline = [{ $match: {. . .} }, { $project: { . . . } }]

var pipeline = [{ $match: { "imdb.rating": { $gte: 7 }, genres: { $nin: ["Crime", "Horror"]}, rated: { $in: ["G", "PG"]}, languages: { $all: ["English", "Japanese"]}}}, { $project: {_id: 0, title: 1, rated: 1}} ]

db.movies.aggregate([{ 
    $match: { 
        "imdb.rating": { $gte: 7 },
        genres: { $nin: ["Crime", "Horror"]},
        rated: { $in: ["G", "PG"]},
        languages: { $all: ["English", "Japanese"]}
        }
}]).itcount()

load('./validateLab2.js')

db.movies.aggregate([
    {
        $project: {
            _id: 0,
            title: 1,
            wordCount: { $size: { $split: [ "$title", ' ']}}
        }
    },
    {
        $match: {
            wordCount: 1
        }
    }
]).itcount()
```
# OPTIONAL LAB

```
mongo "mongodb://cluster0-shard-00-00-jxeqq.mongodb.net:27017,cluster0-shard-00-01-jxeqq.mongodb.net:27017,cluster0-shard-00-02-jxeqq.mongodb.net:27017/aggregations?replicaSet=Cluster0-shard-0" --authenticationDatabase admin --ssl -u m121 -p aggregations --norc

db.movies.findOne({title: "Life Is Beautiful"}, { _id: 0, cast: 1, writers: 1, directors: 1})

writers: {
  $map: {
    input: "$writers",
    as: "writer",
    in: "$$writer"
  }
}

writers: {
  $map: {
    input: "$writers",
    as: "writer",
    in: {
      $arrayElemAt: [
        {
          $split: [ "$$writer", " (" ]
        },
        0
      ]
    }
  }
}

// add the $count stage to the end of your pipeline
// you will learn about this stage shortly!
db.movies.aggregate([
  {$stage1},
  {$stage2},
  {...$stageN},
  { $count: "labors of love" }
])

// or use itcount()
db.movies.aggregate([
  {$stage1},
  {$stage2},
  {...$stageN}
]).itcount()

db.movies.aggregate([
    {
        $project: {
            _id: 0,
            title: 1,
            cast: 1,
            writers: {
                $map: {
                    input: "$writers",
                    as: "writer",
                    in: {
                      $arrayElemAt: [
                        {
                          $split: [ "$$writer", " (" ]
                        },
                        0
                      ]
                    }
                  }
                },
            directors: 1
        }
    },
    { 
        $project: { 
            cast: 1, 
            writers: 1, 
            directors: 1, 
            laborOfLove: { $setIntersection: [ "$cast", "$writers", "$directors"] } 
        } 
    },
    {
        $project: {
            loveSize: { $cond: { if: { $isArray: "$laborOfLove" }, then: { $size: "$laborOfLove" }, else: 0} }
        }
    },
    {
        $match: {
            loveSize: { $gt: 0 }
        }
    },
    { $count: "labors of love" }
])
```
