#!/bin/bash

cd /opt/icinga-plugins/update-checker/applications/postfixadmin/
INSTALLED_VERSION=`./update_installed.sh`
NEW_VERSION=`./update_available.sh`

echo "Installed version: $INSTALLED_VERSION"
echo "Newest version: $NEW_VERSION"

if [ "$INSTALLED_VERSION" == "$NEW_VERSION" ]; then
	echo "Newest version already installed, nothing to do"
	exit
fi

cd /var/www
rm -rf pfa-new pfa.tar.gz postfixadmin-postfixadmin-*

URL="https://github.com/postfixadmin/postfixadmin/archive/postfixadmin-$NEW_VERSION.tar.gz"
wget -q -O pfa.tar.gz "$URL"

tar xvf pfa.tar.gz

mv postfixadmin-postfixadmin-* pfa-new
rm -f pfa.tar.gz

cp postfixadmin/config.local.php pfa-new

chown root:www-data pfa-new

cd pfa-new

find -type f -print0 | xargs -0 chmod 640
find -type f -print0 | xargs -0 chown root:www-data
mkdir templates_c && chmod 750 templates_c && chown -R www-data templates_c

cat functions.inc.php |sed -e "s/^\$version = '.*';$/\$version = '$NEW_VERSION';/" > temp.php
mv temp.php functions.inc.php

sudo -u www-data bash composer-update.sh

cd ..

echo "Hit any key to perform the update now"
read

mv postfixadmin pfa-old
mv pfa-new/ postfixadmin

echo "Run setup.php now"
read

while true; do
	echo -n "Does postfixadmin now work correctly [y/n]? "
	read INPUT
	if [ "$INPUT" == "y" ]; then
		echo "Finally removing old installation..."
		rm -rf pfa-old
		echo "We're done here."

		/opt/icinga-plugins/update-checker/refresh.sh

		exit 0
	elif [ "$INPUT" == "n" ]; then
		echo "Restoring old installation..."
		rm -rf postfixadmin
		mv pfa-old postfixadmin
		echo "We're done here."
		exit 0
	fi
done


