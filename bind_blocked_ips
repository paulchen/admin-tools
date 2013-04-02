#!/bin/bash

if [ "$1" == "autoconf" ]; then
	echo "yes"
	exit
fi
if [ "$1" == "config" ]; then
	echo "graph_title Blocked IP adresses for bind"
	echo "graph_args -l 0"
	echo "graph_vlabel IP addresses"
	echo "graph_category BIND"
	echo "size.label IP addresses"
	echo "graph_info Current number of blocked IP addresses for bind"
	echo "size.info Current number of blocked IP addresses for bind"
	exit
fi

IP_COUNT=`iptables-save |grep -c "dport 53"`
echo "size.value $IP_COUNT"

