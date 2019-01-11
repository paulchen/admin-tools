#!/bin/bash

UPDATE_FILE=/tmp/dehydrated-updates
LOG_FILE=/tmp/dehydrated-logs
ERROR_FILE=/tmp/dehydrated-error

QUIET=0
if [ "$1" == "-q" ]; then
	QUIET=1
fi

rm -f $UPDATE_FILE
rm -f $LOG_FILE
rm -f $ERROR_FILE

ERROR=0

print_date() {
	echo ""
	echo ""
	date
	echo ""
	echo ""
}

fail() {
	ERROR=1
	echo ""
	echo "Fail!"
	echo ""
}

print_date >> $LOG_FILE
/opt/dehydrated/dehydrated -c >> $LOG_FILE 2>&1 || fail
print_date >> $LOG_FILE

cat $LOG_FILE >> /var/log/dehydrated.log

EXIT_CODE=0

if [ -f $UPDATE_FILE ]; then
	if [ "$QUIET" -eq "0" ]; then
		cat $LOG_FILE
	fi
elif [ -f $ERROR_FILE ]; then
	cat $LOG_FILE
	EXIT_CODE=1
elif [ "$ERROR" -ne "0" ]; then
	cat $LOG_FILE
	EXIT_CODE=1
fi

rm -f $LOG_FILE
rm -f $UPDATE_FILE
rm -f $ERROR_FILE

exit $EXIT_CODE
