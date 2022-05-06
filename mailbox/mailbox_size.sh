#!/bin/bash

SIZE1=`ls /var/spool/postfix/virtual/paulchen@rueckgr.at/new|wc -l`
SIZE2=`ls /var/spool/postfix/virtual/paulchen@rueckgr.at/cur|wc -l`
ALL_MAILS=$((SIZE1+SIZE2))
echo $ALL_MAILS > /etc/munin/mailbox_size

SIZE3=`ls /var/spool/postfix/virtual/paulchen@rueckgr.at/new/|sed -e 's+^.*,++'|grep -vc S`
SIZE4=`ls /var/spool/postfix/virtual/paulchen@rueckgr.at/cur/|sed -e 's+^.*,++'|grep -vc S`
UNREAD_MAILS=$((SIZE3+SIZE4))
echo $UNREAD_MAILS > /etc/munin/mailbox_unread_size

cd /var/spool/postfix/virtual/paulchen@rueckgr.at
count=`ls cur/* new/* 2>/dev/null|wc -l`
ages=0
date=`date +%s`
#for a in `ls cur/* new/* 2>/dev/null|sed -e "s/^[^\/]*\///g;s/\..*$//g"`; do
IFS=$'\n'
for a in `grep '^Date:[0-9a-zA-Z,: \+]*$' cur/* new/* 2> /dev/null|sed -e "s/.*Date: *//"`; do
	error=0
	date --date="$a" +%s &> /dev/null || error=1
	if [ "$error" -eq "0" ]; then
		unix=`date --date="$a" +%s`
		age=$((date-unix))
		ages=$((age+ages))
	fi
done
if [ "$count" -eq "0" ]; then
	AVERAGE_AGE=0
else
	AVERAGE_AGE=$((ages/count))
fi
echo $((AVERAGE_AGE/86400)) > /etc/munin/mailbox_avg_age

php /opt/admin-tools/mailbox/mailbox_size.php "$ALL_MAILS" "$UNREAD_MAILS"
