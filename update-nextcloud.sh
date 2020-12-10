#!/bin/bash

# inspired by from https://sysadms.de/2020/08/nextcloud-updates-automatisieren/

ERROR=0

echo "Downloading and installing update"

php /var/www/cloud/updater/updater.phar --no-interaction || ERROR=1

if [ "$ERROR" -eq "0" ]; then
	echo "Executing necessary upgrades"
	php /var/www/cloud/occ upgrade --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Adding missing columns"
	php /var/www/cloud/occ db:add-missing-columns --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Adding missing columns"
	php /var/www/cloud/occ db:add-missing-primary-keys --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Adding missing indices"
	php /var/www/cloud/occ db:add-missing-indices --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Perform any available app updates"
	php /var/www/cloud/occ app:update --all --no-interaction || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	echo "Update successfully completed"
else
	echo "Some error occurred during update"
fi

