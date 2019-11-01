#!/bin/bash
STATEFILE=/root/.fritzbox
if [ ! -f $STATEFILE ]; then
        echo 0 > $STATEFILE
fi
failures=`cat $STATEFILE`
uptime=`cat /proc/uptime|cut -d " " -f 1|sed -e "s+\..*$++"`
date
echo "Current failures: $failures"
echo "Uptime seconds: $uptime"
ping -c 5 fritz.box > /dev/null 2>&1 && failures=0 || failures=$((failures+1))
echo $failures > $STATEFILE
echo "New failures: $failures"
if [ "$uptime" -lt 1800 ]; then
	echo "No further check, less than 30 minutes uptime yet"
elif [ "$failures" -gt 10 ]; then
	echo "Maybe no network. Rebooting..."
	reboot
fi
echo ""

