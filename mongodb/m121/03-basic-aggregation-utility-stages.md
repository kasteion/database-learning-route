# $addFields and How it is similar to $project

$addFields is another transformative stage. It is similar to project with a key diference. $addFields only allows to add a new field o modify an existing field. But project allows to remove fields.

```

db.solarSystem.aggregate([
    {
        $project: { _id: 0, gravity: "$gravity.value", name: 1 }
    }
]).pretty()

db.solarSystem.aggregate([
    {
        $addFields: {
            gravity: "$gravity.value",
            mass: "$mass.value",
            radius: "$radius.value",
            sma: "$sma.value"
        }
    }
]).pretty()

db.solarSystem.aggregate([
    {
        $project: { 
            _id: 0, 
            name: 1,
            gravity: 1, 
            mass: 1,
            radius: 1,
            sma: 1 
        }
    },
    {
        $addFields: {
            gravity: "$gravity.value",
            mass: "$mass.value",
            radius: "$radius.value",
            sma: "$sma.value"
        }
    }
]).pretty()
```

# $geoNear STAGE

Lets get away from transformation for a moment. Lets talk about a useful utility stage if we work with geo JSON data.

$geoNear is an aggregation framework solution to perform geo queries within the aggregation framework pipeline. It must be the first stage in a pipeline and we can use the $near operation.

$geoNear supports charted collections and $near dont.

With $near you cant use other special indexes like $text.

With $geoNear you should have one (and only one) geospatial index.

```
$geoNear: {
    near: <required, the location to search near>,
    distanceField: <required, field to insert in returned documents>,
    minDistance: <optional, in meters>,
    maxDistance: <optional, in meters>,
    query: <optional, allows querying source documents>,
    includeLocs: <optional, used to identify which location was used>,
    limit: <optional, the maximun number of documents to return>,
    num: <optional, same as limit>,
    spherical: <required, required to signal whether using a 2dsphere index>,
    distanceMultiplier: <optional, the factor to multiply all distances>
}

$geoNear: {
    near: { type: "Point", coordinates: [ -73.98, 40.75]}
    distanceField: "distancefromMongoDB",
    spherical: true
}

db.nycFacilities.aggregate([
    {
        $geoNear: {
            near: {
                type: "Point",
                coordinates: [ -73.98769766092299, 40.757345233626594]
            },
            distanceField: "distanceFromMongoDB",
            spherical: true
        }
    }
]).pretty()

db.nycFacilities.aggregate([
    {
        $geoNear: {
            near: {
                type: "Point",
                coordinates: [ -73.98769766092299, 40.757345233626594]
            },
            distanceField: "distanceFromMongoDB",
            spherical: true,
            query: { type: "Hospital" }
        }
    },
    {
        $limit: 5
    }
]).pretty()
```

**Remember**

- The collection can have one and only one 2dsphere index.
- If using 2dsphere, the distance is returned in meters. If using legacy coordinates, the distance is returned in radians.
- $geoNear must be the first stage in an aggregation pipeline.

https://docs.mongodb.com/manual/reference/operator/aggregation/geoNear/?jmp=university

# CURSOR-LIKE STAGES

Lets discuss some useful utility stages. These stages are: $sort, $skip, $limit and $count.

```
$limit: { <integer>}

$skip: { <integer>}

$count: { <name we want the count called>}

$sort: { <field we want to sort on>: <integer, direction of sort>}
```

**Summary**

- $sort, $skip, $limit and $count are functionally equivalent to the similarly named cursor methods.
- $sort can take advantage of indexes if used early within a pipeline.
- By default, $sort will only use up to 100 megabytes of RAM. setting allowDiskUse: true will allow for larger sorts.

# $sample STAGE

Another very useful utility stage is $sample. It will select a set of random documents in a collection in one of two ways:

**First Method**

{ $sample: { size: `< N, how many documents>}`}

WHEN:

N <= 5% of number of documents in source collection AND source collection has >= 100 documents AND $sample is the first stage

THEN: 

A pseudo random cursor will select the specific number of documents to be passed on.

**Second Method**

{ $sample: { size: `< N, how many documents>`}}

WHEN:

All other conditions.

THEN:

There will be an in memory random sort (subject to the 100 Mb restriction) will select the specific number of documents required.

https://docs.mongodb.com/manual/reference/operator/aggregation/sample/?jmp=university

# LAB 01

```
mongo "mongodb://cluster0-shard-00-00-jxeqq.mongodb.net:27017,cluster0-shard-00-01-jxeqq.mongodb.net:27017,cluster0-shard-00-02-jxeqq.mongodb.net:27017/aggregations?replicaSet=Cluster0-shard-0" --authenticationDatabase admin --ssl -u m121 -p aggregations --norc

db.movies.aggregate([
    {
        $match: {
            "tomatoes.viewer.rating": {
                $gte: 3
            },
            countries: {
                $in: ["USA"]
            }
        }
    }, 
    {
        $project: {
            _id: 0,
            title: 1,
            cast: 1,
            tomatoesViewerRating: "$tomatoes.viewer.rating",
            favorites: ["Sandra Bullock","Tom Hanks","Julia Roberts","Kevin Spacey","George Clooney"]
        }
    },
    {
        $addFields: {
            favs: { $setIntersection: [ "$cast", "$favorites" ] }
        }
    }, 
    {
        $addFields: {
            num_favs: { $cond: { if: { $isArray: "$favs" }, then: { $size: "$favs" }, else: 0} }
        }
    }, 
    {
        $match: { num_favs: { $gt: 0}}
    }, 
    {
        $sort: {
            num_favs: -1, 
            tomatoesViewerRating: -1,
            title: -1
        }
    }, 
    { "$limit": 25  }
]).pretty()

```

# LAB

```
db.movies.aggregate([
    {
        $match: {
            languages: { $in: ["English"]},
            "imdb.rating": { $gte: 1 },
            "imdb.votes": { $gte: 1},
            year: { $gte: 1990 }
        }
    },
    {
        $project: {
            _id: 0,
            title: 1,
            imdbVotes: "$imdb.votes",
            imdbRating: "$imdb.rating",
            scaled_votes: {
    $add: [
      1,
      {
        $multiply: [
          9,
          {
            $divide: [
              { $subtract: ["$imdbVotes", 5] },
              { $subtract: [1521105, 5] }
            ]
          }
        ]
      }
    ]
  }
        }
    }, 
    {
        $project: {
            title: 1,
            normalized_rating: { $avg: ["$scaled_votes", "$imdbRating"]}
        }
    },
    {
        $sort: { normalized_rating: 1 }
    }
]).pretty()


{
    $add: [
      1,
      {
        $multiply: [
          9,
          {
            $divide: [
              { $subtract: ["$imdb.votes", 5] },
              { $subtract: [1521105, 5] }
            ]
          }
        ]
      }
    ]
  }
```