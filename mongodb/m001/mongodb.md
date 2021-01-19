# CONNECTING TO MONGODB CLUSTER

> mongo "mongodb+srv://cluster0-url.mongodb.net/" --username kasteion
>
> show dbs
>
> load("loadMovieDetailsDataset.js")
>
> use videos
>
> db.movieDetails.find().pretty()

# INSERT 

> use video
>
> show collections
>
> db.moviesScratch.insertOne({ title: "Star Trek II: The Wrath of Khan", year: 1982, imdb: "tt0084726"})
>
> db.moviesScratch.insertOne({_id: "tt0084726", title: "Star Trek II: The Wrath of Khan", year: 1982, imdb: "tt0084726"})

```
db.moviesScratch.insertMany(
    [
        {
            _id: "tt0084726", 
            title: "Star Trek II: The Wrath of Khan", 
            year: 1982, 
            imdb: "tt0084726"
        },
        {},
        ...
    ],
)
```

Agregando { "ordered": false } la instrucci[on sigue aunque de errores.

```
db.moviesScratch.insertMany(
    [
        {
            _id: "tt0084726", 
            title: "Star Trek II: The Wrath of Khan", 
            year: 1982, 
            imdb: "tt0084726"
        },
        {},
        ...
    ],
    { 
        ordered: false
        }
)
```

# FILTER (QUERY)

> use videos
>
> db.movies.find({ mpaaRating: "PG-13"}).pretty()
>

## READING DOCUMENTS: ARRAY FIELDS

Search for the first elemento of an array to be equal to...

```
{ "cast.0": "Jeff Bridges" }
```

Search exactly this Array:

```
{ cast: [ "Jeff Bridges", "Tim Robbins"]}
```

Search in a text array: 

```
{ cast: "Jeff Bridges" }
```

# CURSORS

`find` returns a cursor, a pointer to a location and you have to iterate throught it (20 Results)

Use `it` to iterate.

# PROJECTION

Reduce the network overhead by reducing the fields we select.

```
db.movies.find({ genre: "Action, Adventure"}, {title: 1})
```

We use 1 to include the field and 0 to exclude the field.

```
{ title: 1, _id: 0 }
```

# UPDATE

`updateOne` updates the first document that matches the query.

$set is the operator of the Update

```
db.movieDetails.updateOne(
    {title: "The Martian"},
    {
        $set: {
            poster: "http://ia.media-imdb.com/images/m/..."
        }
    }
)

db.movieDetails.updateOne(
    {title: "The Martian"},
    {
        $set: {
            "award": {
                "wins": 8,
                "nominations": 14,
                "text": "Nominated to 3 Golden globes, Another..."
            }
        }
    }
)
```

## UPDATE OPERATORS

https://docs.mongodb.com/manual/reference/operator/update

- $inc: Increments the value of the field by the specified amount.
- $set: Sets the value of a field in a document.
- $unset: Removes the specified field from a document.
- $min: Only update the field if the specified value is less than the existing field value.
- $max: Only updates the field if the specified value is greater than the exsiting field value.
- $currentDate: Sets the value of a field to current date, either as a Date or a Timestamp.

```
db.movieDetails(
    { title: "The Martian"},
    {
        $inc: {
            "tomato.reviews": 3,
            "tomato.userReviews": 25
        }
    }
)
```

**Arrays**

- $addToSet: Add elements to an array only if they do not already exists in the set.
- $pop: Removes the first or last item of an array.
- $push: Adds an item to an array.
- $pullAll: Removes all matching values from an array.

```
let reviewText1 = [ "review text" ].join();

db.movieDetails.updateOne(
    {
        title: "The Martian"
    },
    {
        $push: {
            revies: {
                rating: 4.5,
                date: ISODate("2016-01-12T09:00:002"),
                reviewer: "Spencer H.",
                text: reviewText1
            }
        }
    }
)

db.movieDetails.updateOne(
    {
        title: "The Martian"
    },
    {
        $push: {
            reviews: {
                $each: [
                    {
                        rating: 0.5,
                        date: ISODate("2016-01-12T07:00:002"),
                        reviewer: "Yabo A.",
                        text: reviewText2
                    },
                    {...},
                    ...s
                ]
            }
        }
    }
)
```

## UPDATING DOCUMENTS: UPDATEMANY

**updateMany**: Updates all documents...

```
db.movieDetails.updateMany(
    { rated: null },
    {
        $unset: {
            rated: ""
        }
    }
)
```
## UPDATING DOCUMENTS: UPSERTS

```
db.movieDetails.updateOne(
    {
        "imdb.id": detail.imdb.id
    },
    { 
        $set: detail
    },
    {
        upsert: true
    }
)
```

## REPLACEONE

```
let filter = {
    title: "House, M.D., Season Four: New Beginigns" 
};

let doc = db.movieDetails.findOne(filter);

doc.poster = "https://www.imdb.com/title/tt1329264/mediaviewer/rm2619416576";

doc.genres.push("TV Series");

db.movieDetails.replaceOne(filter, doc);
```

# DELETING DOCUMENTS

```
db.reviews.deleteOne();

db.reviews.deleteMany()

./mongo connectionString /video --authenticationDatabase admin --username username --password pass loadReviewsDataset.js
```

# MORE QUERIES

https://docs.mongodb.com/manual/reference/operator/query/

## COMPARISON OPERATORS

$gt = Greater than

```
db.movieDetails.find({runtime: { $gt: 90 }}, { _id: 0, title: 1, runtime: 1})
```

$lt = Lower than

```
db.movieDetails.find({runtime: { $gt: 90 , $lt: 120}})
```

$gte = Greater or equal
$lte = Lower than or equal

```
db.movieDetails.find({runtime: { $gte: 90 , $lte: 120}})
```

$ne = Not equal

```
db.movieDetails.find({rated: { $ne: "UNRATED" }})
```

$in = In the array
$nin = Not in the array

```
db.movieDetails.find({rated: { $in: ["G", "PG", "PG-13"]}})
```

## ELEMENT OPERATORS

- $exists: Let us select documents where a fiels exists.
- $type: Selects documents if the field is of a certain type.

```
db.movieDetails.find({ mpaaRating: { $exists: true}})

db.movieDetails.find({ "tomato.concensus": null})

db.movieDetails.find({ viewerrating: { $type: "int" }})

db.movieDetails.find({ viewerrating: { $type: "double" }})
```

## LOGICAL OPERATORS

- $or
- $and
- $not

```
db.movieDetails.find(
    {
        $or: [
            { "tomato.meter": { $gt: 95 }},
            { "metacritic": { $gt: 88}}
        ]
    }
)

db.movieDetails.find(
    {
        $and: [
            { "tomato.meter": { $gt: 95 }},
            { "metacritic": { $gt: 88}}
        ]
    }
)

// Equivalent to

db.movieDetails.find(
    {
        "tomato.meter": { $gt: 95 },
        "metacritic": { $gt: 88 }
    }
)
```

We can use $and when we want to do two checks on the same field, ex:

```
db.movieDetails.find(
    {
        $and: [
            { "metacritic": { $ne: null }},
            { "metacritic": { $exists: true}}
        ]
    }
)
```
## ARRAY OPERATORS

- **$all**: Finding elements clasified in comedy, Crime and Drama

```
db.movieDetails.find(
    {
        genres: {
            $all: [ "Comedy", "Crime", "Drama" ]
        }
    }
)
```

- **$size**: Queries base on the size of an array. Documents that only have one country

```
db.movieDetails.find(
    {
        countries: {
            $size: 1
        }
    }
)

db.movieDetails.find(
    {
        countries: {
            $size: 1
        }
    }
).count()
```

- **$elemMatch**

```
db.movieDetails.find(
    {
        boxOffice: {
            $elemMatch: {
                "country": "Germany", "revenue": { $gt: 17}
            }
        }
    }
)
```
## REGEX

Selects documents using regular expresions.

Elements that start with "Won " and then comes any other character. 
```
db.movieDetails.find(
    {
        "awards.text": {
            $regex: /^Won .*/
        }
    }
)
```