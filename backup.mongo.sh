#!/bin/bash

error=0

rm -f /tmp/backup_mongo.log

echo "" >> /tmp/backup_mongo.log
date >> /tmp/backup_mongo.log 2>&1 || error=1
echo "" >> /tmp/backup_mongo.log

rm -rf /mnt/backup/mongodb/dump/* >> /tmp/backup_mongo.log 2>&1 || error=1
docker exec mongo mongodump --out=/backup >> /tmp/backup_mongo.log 2>&1 || error=1
cd /mnt/backup/mongodb >> /tmp/backup_mongo.log 2>&1 || error=1
temp_filename=dumps/.dump-$(date +%Y%m%d%H%M%S).tar.bz2
filename=dumps/dump-$(date +%Y%m%d%H%M%S).tar.bz2
tar cjvf "$temp_filename" dump >> /tmp/backup_mongo.log 2>&1 || error=1
mv "$temp_filename" "$filename" || error=1

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

