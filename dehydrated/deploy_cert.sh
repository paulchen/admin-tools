#!/bin/bash

if [ "$1" == "" ]; then
	echo Missing parameter
	exit 1
fi

echo $1 >> /tmp/dehydrated-updates

FILEPATH=`dirname $0`

CONFIGFILE="$FILEPATH/deploy_cert.conf"

if [ ! -f "$CONFIGFILE" ]; then
	echo Configuration file $CONFIGFILE not found
	exit 1
fi

source "$CONFIGFILE"

for domain in "${IRC_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		rsync -av /etc/dehydrated/certs/irc.rueckgr.at/ /etc/inspircd/ssl/
		chown -R irc:irc /etc/inspircd/ssl/
		echo Reloading IRCd configuration due to renewal of certificate for domain $1 ...
		"$FILEPATH/rehash_irc.sh"
	fi
done

for domain in "${POSTFIX_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Restarting Postfix due to renewal of certificate for domain $1 ...
		systemctl restart postfix.service
	fi
done

for domain in "${DOVECOT_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Restarting Dovecot due to renewal of certificate for domain $1 ...
		systemctl restart dovecot.service
	fi
done

for domain in "${APACHE_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Reloading Apache due to renewal of certificate for domain $1 ...
		systemctl force-reload apache2.service
	fi
done

for domain in "${LIGHTTPD_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Reloading LigHTTPd due to renewal of certificate for domain $1 ...
		cat "/etc/dehydrated/certs/$domain/privkey.pem" "/etc/dehydrated/certs/$domain/cert.pem" > "/etc/dehydrated/certs/$domain/lighttpd.pem"
		systemctl force-reload lighttpd.service
	fi
done

for domain in "${XMPP_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Replacing XMPP certificate...
		cat "/etc/dehydrated/certs/$domain/fullchain.pem" "/etc/dehydrated/certs/$domain/privkey.pem" > "/opt/ejabberd/etc/ejabberd/${domain}.pem"
		chown ejabberd:ejabberd "/opt/ejabberd/etc/ejabberd/${domain}.pem"
	fi
done

for domain in "${NAGIOS_CERTS[@]}"; do
        if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
                echo Restarting nagios-nrpe-server due to renewal of certificate for domain $1 ...
                mkdir -p "/etc/nagios/ssl/$domain"
                cp "/etc/dehydrated/certs/$domain/privkey.pem" "/etc/dehydrated/certs/$domain/fullchain.pem" "/etc/nagios/ssl/$domain/"
                chown -R nagios:nagios /etc/nagios/ssl
                systemctl restart nagios-nrpe-server.service
        fi
done

