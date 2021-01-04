#!/bin/bash

DIRECTORY=`dirname "$0"`
cd "$DIRECTORY"

echo "" >> /var/log/speedtest.log
date >> /var/log/speedtest.log
echo "" >> /var/log/speedtest.log

fail=0
./speedtest-munin.py > /tmp/speedtest-stats 2>/tmp/speedtest-error || fail=1

if [ "$fail" -eq "1" ]; then
	cat /tmp/speedtest-error >> /var/log/speedtest.log
	rm -f /tmp/speedtest-error
	rm -f /tmp/speedtest-stats
	exit 1
fi

mv /tmp/speedtest-stats /etc/munin
rm -f /tmp/speedtest-error

touch last-speedtest-update

