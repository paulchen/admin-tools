#!/bin/bash
if [ "$1" == "" ]; then
	echo Missing URL
	exit
fi

echo Downloading...

cd /var/www
rm -rf blog-old drupal temp drupal-new.tar.gz
wget $1 -O drupal-new.tar.gz -q

echo Extracting...

mkdir temp
tar xf drupal-new.tar.gz -C temp
rm drupal-new.tar.gz

echo Preparing...
mv temp/* drupal
rmdir temp
rm -rf drupal/sites
cd blog
cp -i favicon.ico google565776cb02cbae6d.html ../drupal
cp -ri sites tmp images ../drupal
cd ../drupal
ln -s ../jabber/graphs/
ln -s ../jabber/jwchat/
cd ..
chown -R www-data:www-data drupal

echo Hit any key key to perform the update...
read

mv blog blog-old
mv drupal blog

echo Please run update.php now
read

while true; do
	echo -n "Does Drupal now work correctly [y/n]? "
	read INPUT
	if [ "$INPUT" == "y" ]; then
		echo "Finally removing old installation..."
		rm -rf blog-old
		echo "We're done here."
		exit 0
	elif [ "$INPUT" == "n" ]; then
		echo "Restoring old installation..."
		rm -rf blog
		mv blog-old blog
		echo "We're done here."
		exit 0
	fi
done

