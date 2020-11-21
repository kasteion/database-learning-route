# !/bin/bash
mongod -f mongod.conf
mongo admin --host localhost:27000 --eval 'db.createUser({user: "m103-admin",pwd: "m103-pass",roles: [{role: "root", db: "admin"}]})'
