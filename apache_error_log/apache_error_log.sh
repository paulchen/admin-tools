#!/bin/bash

filename=`realpath "$0"`
statusfile=`dirname "$filename"`/last_error_log_check


if [ "$1" == "--convert" ]; then
	while read line; do
		timestamp=`echo "$line"|sed -e "s/^.//;s/\].*//"`
		message=`echo "$line"|sed -e "s/^[^\]]*\]//"`
		converted_date=`date -d "$timestamp" +"%Y-%m-%d-%H:%M:%S.%N"`

		unix=`date -d "$timestamp" +"%s"`
		if [ -f "$statusfile" ]; then
			reference=`stat -c %Y "$statusfile"`
		else
			reference=0
		fi

		if [ "$unix" -gt "$reference" ]; then
			echo "$converted_date $message"
		fi
	done < /dev/stdin
	exit
fi


find /var/www /var/log \( -name error.log -or -name error.log.1 -or -name container-error.log -or -name container-error.log.1 \) -exec cat {} \; |
	grep --text "\[[A-Z][a-z][a-z]" |
	sed -e "s/.*\(\[[A-Z][a-z][a-z] \)/\1/" |
	grep -v "[^p7]:notice" |
	grep -v 'client denied by server configuration' |
	grep -v 'not found or unable to stat' |
	grep -v 'ssl:warn' |
	grep -v 'No matching DirectoryIndex' |
	grep -v 'attempt to invoke directory as script:' |
	grep -v 'provided via SNI, but no hostname provided in HTTP request' |
	grep -v 'provided via SNI and hostname' |
	grep -v 'Invalid URI in request GET' |
	grep -v 'rejecting client initiated renegotiation' |
	grep -v 'None could be negotiated' |
	grep -v 'Action ".*" does not exist' |
	grep -v 'no record of generation [0-9]* of exiting child' |
	grep -v 'Invalid method in request' |
	grep -v 'PostfixAdmin login failed' |
	grep -v 'AH01618' | # user not found
	grep -v 'AH01102' | # error reading status line from server (reverse proxy)
	grep -v 'AH00898' | # error reading from remote server (reverse proxy)
	grep -v 'AH01617' | # user XXX: authentication failure for "...": Password mismatch
	grep -v 'AH01092' | # no HTTP 0.9 request (with no host line) on incoming request and preserve host
	grep -v 'AH01977' | # failed reading line from OCSP server
	grep -v 'AH01980' | # bad response from OCSP server
	grep -v 'AH01941' | # stapling_renew_response: responder error
	grep -v 'AH10291' | # h2_workers: cleanup, x idle workers did not exit after y seconds
	grep -v 'AH10159' | # server is within MinSpareThreads of MaxRequestWorkers, consider raising the MaxRequestWorkers setting
	grep -v 'AH01075' | # Error dispatching request to ...
	grep -v 'AH10508' | # Unsafe URL with %3f URL rewritten without UnsafeAllow3F
	grep -v 'DisplayAction->execute' | # RSS bridge
	grep -v 'Empty module and/or action after parsing the URL' | # Symfony framework
	grep -v 'This request has been forwarded to a 404 error page' | # Symfony framework
	grep -v 'max_statement_time exceeded' |
	grep -v 'File name too long' |
	grep -v '\.\.\/'   | # CVE-2021-41773 attack
	grep -v '\.%2e\/'  | # CVE-2021-41773 attack
	grep -v '%2e%2e\/' | # CVE-2021-41773 attack
	grep -v '%%32%65'  | # CVE-2021-42013 attack
	grep -v 'Primary script unknown' | # php-fpm "404"
	grep -v 'h2_stream.*CLEANUP' | # https://www.apachelounge.com/viewtopic.php?p=41794
	grep -v 'guest token' | # RSS-Bridge's TwitterBridge
	"$filename" --convert |
	sort |
	sed -e "s/^[^ ]* //" |
	grep -v -e '^[[:space:]]*$'


touch "$statusfile"

