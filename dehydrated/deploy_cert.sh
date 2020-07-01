#!/bin/bash


ERROR=0

fail() {
	ERROR=1
	echo "Fail!"
}


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
		rsync -av /etc/dehydrated/certs/irc.rueckgr.at/ /etc/inspircd/ssl/ || fail
		chown -R irc:irc /etc/inspircd/ssl/ || fail
		echo Reloading IRCd configuration due to renewal of certificate for domain $1 ...
		systemctl reload inspircd-custom || fail
		systemctl restart kiwiirc || fail
	fi
done

for domain in "${POSTFIX_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Restarting Postfix due to renewal of certificate for domain $1 ...
		systemctl restart postfix.service || fail
	fi
done

for domain in "${DOVECOT_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		if systemctl status dovecot.service > /dev/null 2>&1; then
			echo Restarting Dovecot due to renewal of certificate for domain $1 ...
			systemctl restart dovecot.service || fail
		fi
		if systemctl status dovecot-custom.service > /dev/null 2>&1; then
			echo Restarting Dovecot due to renewal of certificate for domain $1 ...
			systemctl restart dovecot-custom.service || fail
		fi
	fi
done

for domain in "${APACHE_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Reloading Apache due to renewal of certificate for domain $1 ...
		systemctl force-reload apache2.service || fail
	fi
done

for domain in "${LIGHTTPD_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Reloading LigHTTPd due to renewal of certificate for domain $1 ...
		cat "/etc/dehydrated/certs/$domain/privkey.pem" "/etc/dehydrated/certs/$domain/cert.pem" > "/etc/dehydrated/certs/$domain/lighttpd.pem" || fail
		systemctl force-reload lighttpd.service || fail
	fi
done

for domain in "${XMPP_CERTS[@]}"; do
	if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Replacing XMPP certificate...
		cat "/etc/dehydrated/certs/$domain/fullchain.pem" "/etc/dehydrated/certs/$domain/privkey.pem" > "/opt/ejabberd/etc/ejabberd/${domain}.pem" || fail
		chown ejabberd:ejabberd "/opt/ejabberd/etc/ejabberd/${domain}.pem" || fail
	fi
done

for domain in "${NAGIOS_CERTS[@]}"; do
        if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
                echo Restarting nagios-nrpe-server due to renewal of certificate for domain $1 ...
                mkdir -p "/etc/nagios/ssl/$domain" || fail
                cp "/etc/dehydrated/certs/$domain/privkey.pem" "/etc/dehydrated/certs/$domain/fullchain.pem" "/etc/nagios/ssl/$domain/" || fail
                chown -R nagios:nagios /etc/nagios/ssl || fail
                systemctl restart nagios-nrpe-server.service || fail
        fi
done

for domain in "${ICINGA2_CERTS[@]}"; do
        if [ "$domain" == "all" ] || [ "$domain" == "$1" ]; then
		echo Replacing Icinga2 certificate...
		cp "/etc/dehydrated/certs/$domain/privkey.pem" "/var/lib/icinga2/certs/$domain.key" || fail
		cp "/etc/dehydrated/certs/$domain/fullchain.pem" "/var/lib/icinga2/certs/$domain.crt" || fail
		chown -R nagios:nagios /var/lib/icinga2/certs || fail
		systemctl restart icinga2 || fail
	fi
done

