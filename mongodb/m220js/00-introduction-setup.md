# MONGO DB URI

**uri** = **U**niform **R**esource **I**dentifier

**Standard URI String**

```
mongodb://username:password@
cluster0-shard-00-00-m220-lessons-mcxlm.mongodb.net:27017,
cluster0-shard-00-01-m220-lessons-mcxlm.mongodb.net:27017,
cluster0-shard-00-02-m220-lessons-mcxlm.mongodb.net:27017/mflix
```

**SRV String**

SRV Record or Service Record. Defines its own dns for each server of our cluster.

```
mongodb+srv://username:password@host/authentication-database

mongodb+srv://USERNAME:PASSWORD@Mxxx-zzzz-mcxlm.mongodb.net/admin

mongodb+srv://USERNAME:PASSWORD@Mxxx-zzzz-mcxlm.mongodb.net/admin?retryWrites=true
```

## SETTING UP ATLAS

Load Sample Data.

> mongorestore --gzip --archive=sampledata.archive.gz
