#!/bin/bash

DIRECTORY=`dirname "$0"`
cd "$DIRECTORY"

fail=0
./speedtest-munin.py > /tmp/speedtest-stats 2>/tmp/speedtest-error || fail=1

if [ "$fail" -eq "1" ]; then
	cat /tmp/speedtest-error
	rm -f /tmp/speedtest-error
	exit 1
fi

mv /tmp/speedtest-stats /etc/munin
rm -f /tmp/speedtest-error

