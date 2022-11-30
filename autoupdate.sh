#!/bin/bash

set -o pipefail

post_update() {
	POST_ERROR=0

	case "$1" in
		/var/www/mail/roundcube/plugins/carddav/) sudo -u www-data composer install --no-dev || POST_ERROR=1 ;;
	esac

	return $POST_ERROR
}

git_pull() {
	PULL_ERROR=0

	if [ ! -e "$1" ]; then
		return $PULL_ERROR
	fi

	echo ""
	date
	echo "Updating $1..."
	cd "$1"

	OLD_REVISION=`git rev-parse HEAD`

	git pull || PULL_ERROR=1
	if [ "$2" != "" ]; then
		chown -R "$2" .git
	fi
	echo ""

	NEW_REVISION=`git rev-parse HEAD`

	if [ "$OLD_REVISION" != "$NEW_REVISION" ]; then
		post_update "$1" || PULL_ERROR=1
	fi

	return $PULL_ERROR
}

shutdown() {
	ERROR="$1"
	TMPLOG="$2"

	if [ "$ERROR" -ne "0" ]; then
		cat "$TMPLOG"
	fi

	rm -f "$TMPLOG"

	exit "$1"
}

DIRECTORY=`dirname "$0"`
cd "$DIRECTORY"
DIRECTORY=`pwd`

TMPLOG=/tmp/autoupdate.log

rm -f "$TMPLOG"

ERROR=0

git_pull /var/www/default/web/rss "www-data:www-data" 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/munin-contrib 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
#git_pull /var/www/mail/roundcube/plugins/carddav/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /var/www/default/web/rss/plugins.local/tumblr_gdpr 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/nextcloud-munin-py 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /var/www/default/web/rss-bridge 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/admin-tools 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/icinga-plugins 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /home/paulchen/ipwe "paulchen:paulchen" 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/check_ssl_cert/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/check_sslscan/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/ocsp_proxy/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/pisense/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/check_rpi_temp/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/nagios-rbl-check/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/dehydrated/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1
git_pull /opt/ddns/ 2>&1 | tee -a "$TMPLOG" >> /var/log/autoupdate.log || ERROR=1

/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_installed.sh > /dev/null 2>&1 || shutdown "$ERROR" "$TMPLOG"

INSTALLED=`/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_installed.sh`
AVAILABLE=`/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_available.sh`

if [ "$INSTALLED" != "$AVAILABLE" ]; then
	cd "$DIRECTORY"
	./update-pma/update.sh --auto || ERROR=1
fi

shutdown "$ERROR" "$TMPLOG"

