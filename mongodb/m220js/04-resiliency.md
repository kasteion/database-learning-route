# Connection Pooling

Reusing database connections. The connection pool is cash of database connection that can be re-used.

We could take the lazy aproach and create a new connection every time and destroy the connection once we have used it. The issue with this aproach is that creating a new connection takes time and computer resources, we are paying the cost of creating a new connection each time.

Connection Pooling creates a bunch of connection right of the bat, and as a new request comes in a connection from the pool is used to attend the request.

By default the driver creates a connection pool of 100 connections to share. The default of 100 connections is ok for most applications.

If we are not using a connection pool and sudenly a lot of requests come in we could easily reach the limit of our computer resources.

**Summary**

- Connection pools allow for reuse of connections.
- Subsequent request appear faster to the client.
- Default size of 100 connections.

Mongo Client is initialized in the src/index.js here we can modify the configuration of the MongoClinet to set the maximum size of the connection pool adding poolSize: 50.

# Robust Client Configuration

1. Always use Connection Pooling.

2. Always specify a wtimeout with majority writes. No matter how well we engineer our system we should always expect that application external resources (queues, networks, databases) to take more time than expected.

If we write with w: majority and there is a problem with the secondary nodes. The Acknowledge might take a while. If there are more writes than reads coming this could lead to a database grid lock. To avoid a grid lock we use wtimeout.

{ w "majority", wtimeout: 5000 }

wtimeout is defined in milliseconds.

3. Always configure for and handle **serverSelectionTimeout** errors. No if or buts about it. By handling this error we also pasively monitor the health of our application stack and we become quickly aware of any hardware or software problem that have not been recovered in an addequate amout of time. The driver waits 30 seconds by default before raising a serverSelectionTimeout error. Each driver has a specific way it handles errors.

**Summary**

- Always use connection pooling.
- Always specify a wtimeout with majority writes.
- Always handlw serverSelectionTimeout errors.

We also set wtimeout in the index.js

# Error Handling

Follow along with the lesson with test/lessons/writes-with-error-handling.spec.js

Distributed systems are prone to network errors. While Concurrent system are more likely to find duplicate key errors.

**Summary**

The errors we coveresd in this lesson are:

- Duplicate Key errors
  - Create a new \_id and retry the write
- Timeout errors
  - Lower the write concern value, or increase the wtimeoutMS.
- Write Concern erros
  - Lower the write concern value

Make sure to use a try/catch block to handle these errors gracefully.

# Principle of Least Privilege

Every program and every privileged usedr of the system should operate using the least amount of privilege necessary to complete the job. - Jerome Saltzer, Communications of the ACM

By creating a specific user for the application we can in a more granular way control the access of this user. If an application has the permission to access a collection that it should not use it is a vulnerability in our aplication.

**Summary**

- Engineer systems with the principle of least privilege in mind.
- Consider what kinds of users and what permission they will have.
  - Application users that log into the application itself.
  - Database users.
    - Administrative database userls that can create indexes, import data, and so on.
    - Application database users that only have privileges they require.
