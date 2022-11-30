#!/bin/bash

CONFIG_FILE=`dirname $0`/nextcloud.conf

if [ ! -e "$CONFIG_FILE" ]; then
	echo "Configuration file $CONFIG_FILE not found"
	exit 3
fi

. "$CONFIG_FILE"

if [ ! -f "$DIRECTORY/occ" ]; then
	echo "Invalid NextCloud directory: $DIRECTORY"
	exit 3
fi

USER=`stat -c '%U' "$DIRECTORY/occ"`
CURRENT_USER=`whoami`

if [ "$USER" != "$CURRENT_USER" ]; then
	if [ "$CURRENT_USER" != "root" ]; then
		echo "Please run this script either as user $USER or as root"
		exit 3
	fi

	sudo -u "$USER" "$0"
	exit
fi


# inspired by from https://sysadms.de/2020/08/nextcloud-updates-automatisieren/

ERROR=0

echo "Downloading and installing update"

php "$DIRECTORY/updater/updater.phar" --no-interaction || ERROR=1

if [ "$ERROR" -eq "0" ]; then
	echo "Executing necessary upgrades"
	php "$DIRECTORY/occ" upgrade --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Adding missing columns"
	php "$DIRECTORY/occ" db:add-missing-columns --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Adding missing columns"
	php "$DIRECTORY/occ" db:add-missing-primary-keys --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Adding missing indices"
	php "$DIRECTORY/occ" db:add-missing-indices --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Executing BigInt database conversion"
	php "$DIRECTORY/occ" db:convert-filecache-bigint --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Perform any available app updates"
	php "$DIRECTORY/occ" app:update --all --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Update successfully completed"
else
	echo "Some error occurred during update"
	exit 1
fi

