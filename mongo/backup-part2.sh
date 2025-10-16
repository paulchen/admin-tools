#!/bin/bash

cd /mnt/backup/mongodb || exit 1
temp_filename=dumps/.dump-$(date +%Y%m%d%H%M%S).tar.bz2
filename=dumps/dump-$(date +%Y%m%d%H%M%S).tar.bz2
tar cjvf "$temp_filename" dump || exit 1
mv "$temp_filename" "$filename" || exit 1

