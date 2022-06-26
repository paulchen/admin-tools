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
	if [ "$1" != "-f" ]; then
		echo "Nothing to do"
		exit 0
	else
		echo "Forced update although code base is unchanged"
	fi
fi

docker pull archlinux:base || exit 1
docker pull archlinux:base-devel || exit 1

cd /opt/wordle-archive

USER="`stat -c '%U' .`"

sudo -u "$USER" git pull || exit 1

sudo -u "$USER" docker build . -t wordle-archive --no-cache || exit 1

systemctl restart wordle-archive || exit 1

/opt/icinga-plugins/update-checker/refresh.sh || exit 1

