#!/bin/bash
URL1=$1
URL2=$2

rm -rf repo
git clone --mirror $URL1 repo
cd repo/
git remote remove origin
git remote add origin $URL2
git push origin --mirror
cd ..
rm -rf repo


