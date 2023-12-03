#!/bin/bash

INSTALLED=`/opt/icinga-plugins/update-checker/applications/roundcube/update_installed.sh`
AVAILABLE=`/opt/icinga-plugins/update-checker/applications/roundcube/update_available.sh`

echo "Installed version: $INSTALLED"
echo "Available version: $AVAILABLE"
if [ "$AVAILABLE" == "$INSTALLED" ]; then
	echo "Most recent version already installed, nothing to do"
	exit
fi

cd /tmp

URL="https://github.com/roundcube/roundcubemail/releases/download/$AVAILABLE/roundcubemail-$AVAILABLE-complete.tar.gz"

cd /tmp
rm -f roundcube.tar.gz
rm -rf "roundcubemail-$AVAILABLE"
wget "$URL" -O roundcube.tar.gz
tar -xvf roundcube.tar.gz
rm -f roundcube.tar.gz

cd "roundcubemail-$AVAILABLE"
bin/installto.sh /var/www/mail/roundcube/
cd /tmp
rm -rf "roundcubemail-$AVAILABLE"

cd /var/www/mail

chown -R www-data:www-data roundcube

cd /var/www/mail/roundcube

sudo -u www-data php composer.phar self-update
sudo -u www-data php composer.phar update --no-dev

/opt/icinga-plugins/update-checker/refresh.sh

