#!/bin/bash

SUCCESS=0

BACKUP_SCRIPT="$1"
BACKUP_FILENAME="/tmp/current_backup_$2"
LOGFILE=/var/log/backup.log
if [ "$3" != "" ]; then
	LOGFILE=/var/log/backup-$3.log
fi

"$BACKUP_SCRIPT" > "$BACKUP_FILENAME" 2>&1 && SUCCESS=1

cat "$BACKUP_FILENAME" >> "$LOGFILE"

if [ "$SUCCESS" -ne "1" ]; then
	echo Error running backup script
	cat "$BACKUP_FILENAME"
fi
rm -f "$BACKUP_FILENAME"

