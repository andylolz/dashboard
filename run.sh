#!/bin/bash

set -e

cd IATI-Dashboard
rm -rf stats-calculated stats-blacklist

# Fetch the necessary calculated stats
./get_stats.sh &> /dev/null
./git.sh

# setup the output directory
git clone --branch gh-pages https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/andylolz/dashboard.git out
cd out
rm -rf *
cp ../web/* .

# push output to github
git add --all
git commit -m "auto"
git push origin gh-pages
cd ..

cd ..
