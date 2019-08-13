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


cd /var/
find . \( -name error.log -or -name error.log.1 \) -exec cat {} \; |
	grep -v "^[^\[]" |
	grep -v 'client denied by server configuration' |
	grep -v 'not found or unable to stat' |
	grep -v ':notice' |
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
	grep -v 'DisplayAction->execute' | # RSS bridge
	"$filename" --convert |
	sort |
	sed -e "s/^[^ ]* //" |
	grep -v -e '^[[:space:]]*$'


touch "$statusfile"

