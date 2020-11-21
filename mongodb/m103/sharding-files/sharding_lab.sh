#!/bin/bash

mongoimport --port 26000 -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin" -d "m103" -c "products" /dataset/products.json
mongo --port 26000 -u "m103-admin" -p "m103-pass" --authenticationDatabase "admin"
show dbs
use m103
sh.enableSharding("m103")
db.products.findOne()
db.products.createIndex( { "sku" : 1 } )
sh.shardCollection("m103.products", { "sku" : 1 })
