#!/bin/bash

stop_unit() {
	UNIT=$1
	echo "Stopping $1..."
	ERROR=0
	systemctl stop "$1" || ERROR=1
	if [ "$ERROR" -eq "1" ]; then
		echo "An error occurred while stopping $1"
		exit 1
	fi
}

start_unit() {
	UNIT=$1
	echo "Starting $1..."
	ERROR=0
	systemctl start "$1" || ERROR=1
	if [ "$ERROR" -eq "1" ]; then
		echo "An error occurred while starting $1"
		exit 1
	fi
}

USER="`whoami`"
if [ "`whoami`" != "root" ]; then
	echo You need to run this script as root
	exit 1
fi

cd /opt/icinga-plugins/update-checker/applications/mongo

INSTALLED=`./update_installed.sh`
AVAILABLE=`./update_available.sh`

echo "Installed: $INSTALLED"
echo "Available: $AVAILABLE"

if [ "$INSTALLED" == "$AVAILABLE" ]; then
	echo "Nothing to do"
	exit 0
fi

docker pull "mongo:$AVAILABLE" || exit 1

stop_unit rocketchat-dev
stop_unit docker-munin-mongodb
stop_unit rocketchat-archive
stop_unit kotlin-rocket-bot
stop_unit rocketchat
stop_unit mongo

echo "MONGO_VERSION=$AVAILABLE" > /etc/default/mongo

sleep 15

start_unit mongo

sleep 20

start_unit rocketchat
start_unit kotlin-rocket-bot
start_unit rocketchat-archive
start_unit docker-munin-mongodb
start_unit rocketchat-dev

/opt/icinga-plugins/update-checker/refresh.sh || exit 1

