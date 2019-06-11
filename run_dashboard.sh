#!/bin/bash

set -e

cd IATI-Dashboard

# setup the output directory
rm -rf out
git clone --branch gh-pages https://github.com/andylolz/dashboard.git out
cd out
rm -rf *
cd ..

# Fetch the necessary calculated stats
./get_stats.sh

# # Move generated stats into place
# rm -rf stats-blacklist stats-calculated
# mv ../IATI-Stats/stats-blacklist stats-blacklist
# mv ../IATI-Stats/gitout stats-calculated

# Fetch some extra data from github and github gists
./fetch_data.sh

python plots.py
python make_csv.py
python make_html.py

cp static/img/favicon.png out/
cp static/img/tablesorter-icons.gif out/

# push output to github
cd out
git add --all
git commit -m "auto"
git push origin gh-pages
cd ..

cd ..
