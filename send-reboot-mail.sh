#!/bin/bash

MAIL_FILE=/tmp/reboot-mail
HOSTNAME=`hostname`
MAILTO=paulchen@rueckgr.at
TIME_URL=https://rueckgr.at/~paulchen/time.php

rm -f "$MAIL_FILE"
wget -q -O "$MAIL_FILE" $TIME_URL
echo Reboot of $HOSTNAME successful. >> "$MAIL_FILE"
cat "$MAIL_FILE" | mail -s "Reboot" "$MAILTO"
rm -f "$MAIL_FILE"

