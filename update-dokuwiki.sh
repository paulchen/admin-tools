#!/bin/bash

# create backup
cd /home/paulchen/public_html
rm -f /home/paulchen/dokuwiki-backup.tar.gz
tar zcpfv /home/paulchen/dokuwiki-backup.tar.gz dokuwiki

# download new Dokuwiki
cd /tmp
rm -f dokuwiki-stable.tgz
wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz

# unzip new Dokuwiki
mkdir dokuwiki-stable
tar xvf dokuwiki-stable.tgz -C dokuwiki-stable
rm dokuwiki-stable.tgz

# copy new Dokuwiki over old one
cp -af dokuwiki-stable/*/* /home/paulchen/public_html/dokuwiki/
rm -rf dokuwiki-stable

# remove unused files
cd /home/paulchen/public_html/dokuwiki/
grep -Ev '^($|#)' data/deleted.files | xargs -n 1 rm -vf

# fix permissions
chown -R www-data:www-data /home/paulchen/public_html/dokuwiki/

# remove update notification on web page
rm -f /home/paulchen/public_html/dokuwiki/cache/messages.txt

