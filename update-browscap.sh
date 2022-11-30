#!/bin/bash

error=0
if [ "$1" == "" ]; then
	echo "Directory not specified"
	exit 1
fi
cd "$1" || error=1
if [ "$error" == "1" ]; then
	echo "Unable to use directory $1"
	exit 1
fi

DOWNLOADED=`grep Released full_php_browscap.ini|sed -e "s/^.*=//"`
AVAILABLE=`wget -q -O - https://browscap.org/version`

if [ "$DOWNLOADED" == "" ]; then
	echo "Unable to determine downloaded version"
	exit 1
fi
if [ "$AVAILABLE" == "" ]; then
	echo "Unable to determine available version"
	exit 1
fi

if [ "$DOWNLOADED" != "$AVAILABLE" ]; then
	wget -q -O full_php_browscap.ini.new https://browscap.org/stream?q=Full_PHP_BrowsCapINI || error=1
	if [ "$error" -eq "0" ]; then
		rm full_php_browscap.ini
		mv full_php_browscap.ini.new full_php_browscap.ini
	else
		echo "Unable to download new version"
		exit 1
	fi
fi
touch last_check

