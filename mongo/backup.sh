#!/bin/bash

cd `dirname "$0"`

error=0

rm -f /tmp/backup_mongo.log

echo "" >> /tmp/backup_mongo.log
date >> /tmp/backup_mongo.log 2>&1 || error=1
echo "" >> /tmp/backup_mongo.log

./backup-part1.sh >> /tmp/backup_mongo.log 2>&1 || error=1
./backup-part2.sh >> /tmp/backup_mongo.log 2>&1 || error=1

echo "" >> /tmp/backup_mongo.log
date >> /tmp/backup_mongo.log 2>&1 || error=1
echo "" >> /tmp/backup_mongo.log

cat /tmp/backup_mongo.log >> /var/log/backup_mongo.log

if [ "$error" -ne "0" ]; then
	cat /tmp/backup_mongo.log
	rm -f /tmp/backup_mongo.log
	exit 1
fi

touch /etc/icinga/mongo-backup-date
rm -f /tmp/backup_mongo.log

