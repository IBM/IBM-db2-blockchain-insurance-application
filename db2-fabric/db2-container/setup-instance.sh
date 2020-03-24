#!/bin/bash

DBM_CFG_REGEX='\([_A-Z0-9]*\)=\([_A-Za-z0-9]*\)'

echo

echo
echo "  ====  Connecting to Db2"
echo

db2 connect to testdb

echo

echo
echo "  ====  Updating DB2 Database Manager Configuration"
echo

for l in $(cat /db2-container/db2-dbm.env); do 

    key=$(echo $l | sed 's/'${DBM_CFG_REGEX}'/\1/')
    value=$(echo $l | sed 's/'${DBM_CFG_REGEX}'/\2/')

    echo "    -> $key => $value"

    db2 update database manager configuration using $key $value
done

db2set DB2_JVM_STARTARGS="-Djava.util.logging.config.file=/db2-container/logging.properties"

echo

echo
echo "  ====  Disconnecting from DB2"
echo

db2 disconnect all
db2 terminate

echo