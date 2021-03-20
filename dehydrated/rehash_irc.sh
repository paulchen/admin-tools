#!/bin/bash

cd `dirname $0`
. passwords.conf

# Force IRC server rehash - password must match that at the bottom of /etc/inspircd/opers.conf
username=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 20 | head -n 1)
exec 3<>/dev/tcp/localhost/6667
echo "NICK $username" >&3
echo "USER LetsEncrypt 0 0 :Lets Encrypt auto-update script" >&3
timeout 2s cat <&3
echo "OPER $IRC_USERNAME $IRC_PASSWORD" >&3
timeout 2s cat <&3
#echo "REHASH" >&3
echo "REHASH -ssl" >&3
echo QUIT >&3
timeout 2s cat <&3
