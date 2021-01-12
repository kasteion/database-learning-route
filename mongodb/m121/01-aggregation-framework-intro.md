# M121: MONGODB AGGREGATION FRAMEWORK

We will learn:
- Expressive filteriong
- Powerful data transformation
- Statistical utilities & data analysis
- How to do much more work with a single operation

Beginners course focused on developer practices.

- Transform data
- Perform data analysis
- Let the server do the work, not the client.

# REQUIREMENTS

To connect to M121 course Atlas Cluster, using the mongo shell, you will need to use the following connnection command:

> mongo "mongodb://cluster0-shard-00-00-jxeqq.mongodb.net:27017,cluster0-shard-00-01-jxeqq.mongodb.net:27017,cluster0-shard-00-02-jxeqq.mongodb.net:27017/aggregations?replicaSet=Cluster0-shard-0" --authenticationDatabase admin --ssl -u m121 -p aggregations --norc

Once you've connected, list the existing collections of the aggregations database. You output should be similar to this one:

> show collections

- air_airlines
- air_alliances
- air_routes
- bronze_banking
- customers
- employees
- exoplanets
- gold_banking
- icecream_data
- movies
- mycFacilites
- silver_banking
- solarSystem
- stocks
- system.views

# THE CONCEPT OF PIPELINES

It can be compared with an assembly line in a factory with one or many stages across the assembly line. Depending on what we want to acomplish we can have one or many stages. In each stage we transform the data...

$match ---- $project ---- $group

Pipelines are a composition of stages.

Stages are configurable for transformation.

Documents flow trought the stages like an assembly line or water trought a pipe.

Stages can be arranged in any way we like and as many as we require (With few exceptions)

# AGREGATION STRUCTURE AND SYNTAX

The agregation framework has a simple and reliable strutcture and repeatable syntax. Pipelines may contain one or more stages. Each stage is a json object of key value. We can pass options to.

```
db.solarSystem.aggragate([{
    $match: {
        atmosphericComposition: { $in: [/O2/]},
        meanTemperature: { $gte: -40, $lte: 40 }
    }
}, {
    $project: {
        _id: 0,
        name: 1, 
        hasMoons: { $gt: ["$numberOfMoons", 0] }
    }
}], { allowDiskUse: true }
)
```

- Operators: Either query operators or aggregation stages.
    - $match & $project are aggregation operators.
    - $in, $gte, $lte are query operators.
- Expression: Act like functions, we provide arguments and they produce new values. 
    - $gt and "$numberOfMoons" are Expresssions.

- Field Path: "$fieldName" ("$numberOfMoons")
- System Variable: "$$UPERCASE" ("$$CURRENT")
- User Variable: "$$foo"

- Pipelines are always an array of one or more stages
- Stages are composed of one or more aggregation operators or expressions.
    - Expressions may take a single argument or an array of arguments. This is expressions dependant.

