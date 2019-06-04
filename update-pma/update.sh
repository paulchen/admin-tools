#!/bin/bash
SCRIPT_FILENAME=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_FILENAME"`

cd "$SCRIPT_DIR"
if [ ! -f pma.config ]; then
	echo "pma.config not found, exiting now"
	exit 1
fi

. pma.config

INSTALLED=`/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_installed.sh`
AVAILABLE=`/opt/icinga-plugins/update-checker/applications/phpmyadmin/update_available.sh`

echo Currently installed version: $INSTALLED
echo Latest available version: $AVAILABLE

if [ "$INSTALLED" == "$AVAILABLE" ]; then
	echo "Nothing to do"
	exit
fi

echo Creating backup...

cd "$PMA_INSTALL_DIR"
mkdir -p pma-backups
BACKUP_FILE="pma-backups/backup-`date +%Y%m%d-%H%M%S`.tar.bz2"
tar cjf "$BACKUP_FILE" pma

echo Removing outdated backups...
cd pma-backups
ls -t | tail -n +6 | xargs -I {} rm {}

echo Downloading...

VERSION=$AVAILABLE

LINK=https://files.phpmyadmin.net/phpMyAdmin/$VERSION/phpMyAdmin-$VERSION-all-languages.tar.gz

echo Filename: $LINK

cd /tmp
wget $LINK -q -O pma.tar.bz2
cd $PMA_INSTALL_DIR
mkdir pma-new
cd pma-new
tar xf /tmp/pma.tar.bz2
rm /tmp/pma.tar.bz2
mv * ../pma-new2
cd ..
rmdir pma-new
cp pma/config.inc.php pma-new2
mkdir pma-new2/tmp
chown www-data:www-data pma-new2/tmp
cd pma-new2
patch -p1 < $SCRIPT_DIR/pma.patch
cd ..
chown -R www-data:www-data pma-new2

if [ "$1" != "--auto" ]; then
	echo Hit any key key to perform the update...
	read
fi

mv pma pma-old
mv pma-new2 pma

if [ "$1" == "--auto" ]; then
	echo "Finally removing old installation..."
	rm -rf pma-old
	echo "We're done here."

	/opt/icinga-plugins/update-checker/refresh.sh

	exit 0
fi

while true; do
	echo -n "Does phpMyAdmin now work correctly [y/n]? "
	read INPUT
	if [ "$INPUT" == "y" ]; then
		echo "Finally removing old installation..."
		rm -rf pma-old
		echo "We're done here."

		/opt/icinga-plugins/update-checker/refresh.sh

		exit 0
	elif [ "$INPUT" == "n" ]; then
		echo "Restoring old installation..."
		rm -rf pma
		mv pma-old pma
		echo "We're done here."
		exit 0
	fi
done

