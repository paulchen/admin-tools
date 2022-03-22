#!/bin/bash

USER="`whoami`"
if [ "`whoami`" != "root" ]; then
	echo You need to run this script as root
	exit 1
fi

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

USER="`stat -c '%U' .`"

sudo -u "$USER" git pull || exit 1

sudo -u "$USER" docker build . -t wordle-archive || exit 1

systemctl restart wordle-archive || exit 1

/opt/icinga-plugins/update-checker/refresh.sh || exit 1

