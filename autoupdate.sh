#!/bin/bash

git_pull() {
	if [ ! -e "$1" ]; then
		return
	fi

	echo ""
	date
	echo "Updating $1..."
	cd "$1"

	git pull
	if [ "$2" != "" ]; then
		chown -R "$2" .git
	fi
	echo ""
}

DIRECTORY=`dirname "$0"`

cd "$DIRECTORY"
DIRECTORY=`pwd`
STATUS_FILE="$DIRECTORY/autoupdate.status"

/opt/icinga-plugins/check_fileage.py -f "$STATUS_FILE" -w 150 -c 160 >> /dev/null 2>&1 && exit

ERROR=0

git_pull /var/www/default/web/rss >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /opt/munin-contrib >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /var/www/mail/roundcube/plugins/carddav/ >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /var/www/default/web/rss/plugins.local/tumblr_gdpr >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /opt/nextcloud-munin-py >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /var/www/default/web/rss-bridge >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /opt/admin-tools >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /opt/icinga-plugins >> /var/log/autoupdate.log 2>&1 || ERROR=1
git_pull /home/paulchen/ipwe "paulchen:paulchen" >> /var/log/autoupdate.log 2>&1 || ERROR=1

/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_installed.sh > /dev/null 2>&1 || exit 0

INSTALLED=`/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_installed.sh`
AVAILABLE=`/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_available.sh`

if [ "$INSTALLED" != "$AVAILABLE" ]; then
	cd "$DIRECTORY"
	./update-pma/update.sh --auto || ERROR=1
fi

if [ "$ERROR" -eq "0" ]; then
	pwd
	touch "$STATUS_FILE"
fi

exit "$ERROR"

