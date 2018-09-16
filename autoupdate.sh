#!/bin/bash

git_pull() {
	echo ""
	date
	echo "Updating $1..."
	cd "$1"
	git pull
	echo ""
}

git_pull /var/www/default/web/rss >> /var/log/autoupdate.log 2>&1
git_pull /opt/munin-contrib >> /var/log/autoupdate.log 2>&1 
git_pull /var/www/mail/roundcube/plugins/carddav/ >> /var/log/autoupdate.log 2>&1 

