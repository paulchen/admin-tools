#!/bin/bash

set -o pipefail

DIRECTORY=`dirname "$0"`
cd "$DIRECTORY"

. config.github

LINK="https://api.github.com/user/repos?per_page=10"

ERROR=0
while true; do
	REPOS=`curl -H "Authorization: token $TOKEN" "$LINK" 2>/dev/null |grep full_name|sed -e 's/^.*: "//;s/".*$//'`
	if [ "$?" -ne "0" ]; then
		echo "Unable to fetch list of repositories"
		exit 1
	fi
	for REPO in $REPOS; do
		echo "Repository $REPO..."

		cd "$BASEDIR"
		mkdir -p "$REPO"
		cd "$REPO"

		if [ -e .git ]; then
			git config --get pull.rebase > /dev/null 2>&1 || git config pull.rebase false
			git pull 2>&1 || ERROR=1
		else
			cd ..
			git clone "git@github.com:$REPO" 2>&1 || ERROR=1
			cd "$BASEDIR"
			cd "$REPO"
			git config pull.rebase false
		fi
	done

	IFS_OLD="$IFS"
	export IFS=','

	LINKS=$(curl --head -H "Authorization: token $TOKEN" "$LINK" 2>/dev/null|grep -i '^Link:'|sed -e 's/^Link: //gi')
	if [ "$?" -ne "0" ]; then
		echo "Unable to fetch link to next page of repositories"
		exit 1
	fi
	FOUND=0
	for CANDIDATE_LINK in $LINKS; do
		if [ "`echo $CANDIDATE_LINK|grep -c next`" -ne "0" ]; then
			FOUND=1
			LINK="`echo $CANDIDATE_LINK|sed -e 's/^.*<//;s/>.*//'`"	
			break
		fi
	done
	export IFS="$IFS_OLD"

	if [ "$FOUND" -eq "0" ]; then
		break
	fi

done

if [ "$ERROR" -eq "0" ]; then
	touch "$STATUSFILE"
fi

exit $ERROR

