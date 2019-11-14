#!/bin/bash

DIRECTORY=`dirname "$0"`
cd "$DIRECTORY"

ADMIN_TOOLS_DIR="`pwd`"
ICINGA_PLUGINS_DIR=/opt/icinga-plugins
LOG_FILE=/var/log/process-updates.log
ERROR_FILE="$ADMIN_TOOLS_DIR/.failed-update"

echo "" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

date >> "$LOG_FILE"
echo "Starting execution" >> "$LOG_FILE"

error=0

outdated_status=0
"$ICINGA_PLUGINS_DIR/check_fileage.py" -w 180 -c 200 -f "$ICINGA_PLUGINS_DIR/update-checker/update.status" >> "$LOG_FILE" 2>&1 || outdated_status=1

if [ "$outdated_status" -eq "1" ]; then
	echo "File $ICINGA_PLUGINS_DIR/update-checker/update.status is outdated or does not exist" >> "$LOG_FILE"

	skip_updates=0
	if [ -e "$ERROR_FILE" ]; then
		echo "$ERROR_FILE exists, checking age" >> "$LOG_FILE"
		"$ICINGA_PLUGINS_DIR/check_fileage.py" -w 60 -c 70 -f "$ERROR_FILE" >> "$LOG_FILE" 2>&1 && skip_updates=1
		if [ "$skip_updates" -eq "1" ]; then
			echo "$ERROR_FILE is not old enough, skipping update" >> "$LOG_FILE"
		fi
	fi

	if [ "$skip_updates" -eq "0" ]; then
		echo "Executing autoupdate.sh" >> "$LOG_FILE"
		"$ADMIN_TOOLS_DIR/autoupdate.sh" >> "$LOG_FILE" 2>&1 || error=1
	
		if [ "$error" -eq "0" ]; then
			echo "Executing refresh.sh" >> "$LOG_FILE"
			"$ICINGA_PLUGINS_DIR/update-checker/refresh.sh" >> "$LOG_FILE" 2>&1 || error=1
		else
			echo "Not executing refresh.sh due to previous error" >> "$LOG_FILE"
		fi

		if [ "$error" -eq "0" ]; then
			echo "Everything fine, Removing $ERROR_FILE" >> "$LOG_FILE"
			rm -f "$ERROR_FILE"
		else
			echo "An error occurred, touching $ERROR_FILE" >> "$LOG_FILE"
			touch "$ERROR_FILE"
		fi
	else
		error=1
	fi
else
	echo "File $ICINGA_PLUGINS_DIR/update-checker/update.status is not old enough, not doing anything now" >> "$LOG_FILE"
fi

date >> "$LOG_FILE"
echo "Execution completed; exit code: $error" >> "$LOG_FILE"

exit $error

