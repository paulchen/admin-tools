#!/bin/bash

CURRENT_DIR=`readlink -f /opt/apache-tomcat`
NEW_VERSION=`/opt/icinga-plugins/update-checker/applications/tomcat/update_available.sh`
#NEW_VERSION=9.0.13
NEW_DIR=/opt/apache-tomcat-$NEW_VERSION
DOWNLOAD_URL="http://mirror.klaus-uwe.me/apache/tomcat/tomcat-9/v$NEW_VERSION/bin/apache-tomcat-$NEW_VERSION.tar.gz"
#DOWNLOAD_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.13/bin/apache-tomcat-9.0.13.tar.gz"
DOWNLOAD_FILE=/opt/tomcat.tar.gz

echo "Current installation directory: $CURRENT_DIR"
echo "New installation directory: $NEW_DIR"

if [ "$CURRENT_DIR" == "$NEW_DIR" ]; then
	echo "Already up-to-date, nothing to do"
	exit
fi

rm -rf "$NEW_DIR"
rm -f "$DOWNLOAD_FILE"

echo Downloading new tomcat...

wget "$DOWNLOAD_URL" -O "$DOWNLOAD_FILE"

cd /opt
tar xvf "$DOWNLOAD_FILE"
rm -f "$DOWNLOAD_FILE"

rm -rf "$NEW_DIR/conf" "$NEW_DIR/logs"
mkdir "$NEW_DIR/conf" "$NEW_DIR/logs"

echo Stopping tomcat...

systemctl stop tomcat

sleep 10

echo Executing update...

rsync -av "$CURRENT_DIR/conf/" "$NEW_DIR/conf/"
rsync -av "$CURRENT_DIR/logs/" "$NEW_DIR/logs/"

cp "$CURRENT_DIR/bin/setenv.sh" "$NEW_DIR/bin/"
cp -P "$CURRENT_DIR"/webapps/*.war "$NEW_DIR/webapps"

chown -R jenkins:jenkins "$NEW_DIR"

rm -f apache-tomcat
ln -s "$NEW_DIR" "apache-tomcat"

echo Starting tomcat...

systemctl start tomcat

echo Waiting for keystroke...
read

rm -rf "$CURRENT_DIR"

/opt/icinga-plugins/update-checker/refresh.sh

