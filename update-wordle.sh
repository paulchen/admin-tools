#!/bin/bash

cd /opt/icinga-plugins/update-checker/applications/wordle-archive

INSTALLED=`./update_installed.sh`
AVAILABLE=`./update_available.sh`

echo "Installed: $INSTALLED"
echo "Available: $AVAILABLE"

if [ "$INSTALLED" == "$AVAILABLE" ]; then
	echo "Nothing to do"
	exit 0
fi

cd /opt/wordle-archive

git pull || exit 1

docker build . -t wordle-archive || exit 1

sudo systemctl restart wordle-archive || exit 1

sudo /opt/icinga-plugins/update-checker/refresh.sh || exit 1

