# MongoClient

We can use a MongoClient object to:

- Instantiate a connection to the database
- Gather information about a database or collection
- Create direct connections to collections, which we can issue queries against.

Follow along with ./mflix-js/test/lessons/mongoclient.spec.js

# Asynchronous Programming in Node.js

Follow along with ./mflix-js/test/lessons/callbacks-promises-async.spec.js

> npm test -t callbacks-promises-async.spec.js

We saw 3 different ways to handle asynchronous programming with the MongoDB Node driver, callbacks, promises and async/await.

A few things to remeber:

- You should always wrap await statements with a try/catch block.
- If you aren't confortable with Promises, you can supply a callback to the driver methods that are asynchronous.
- If you don't pass a callback, a Promise will be returned.

https://medium.com/front-end-weekly/callbacks-promises-and-async-await-ad4756e01d90

# Basic Reads

Follow along with ./mflix-js/test/lessons/basic-reads.spec.js

> npm test -t basic-reads

We saw hot to limit the results to one document or get all documents that match a query filter. We also saw how to include only the fields we wanted in the result set, and how to remove the \_id field.

A few things to keep in mind:

- finding one document typically involves querying on a unique index, such as the \_id field.
- When projecting, by specifying inclusion - {title: 1} for example - all fields we don't include will be excluded, except for the \_id field if we don't wnat the \_id field returned to us we must explicitly exclude it, like {title: 1, \_id: 0}
