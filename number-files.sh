#!/bin/bash

counter=0
width=2

if [ "$1" != "" ]; then
	counter=0
	counter=$((counter-1))

	if [ "$2" != "" ]; then
		width=$2
	fi
fi

ls -tcr| while IFS='$\n' read -r filename; do counter=$((counter+1)); prefix=`printf "%0${width}d" $counter`; echo mv "$filename" "$prefix-$filename"; done

