#!/bin/bash

set -e

cd IATI-Stats

# fetch data
rm -rf data
wget https://www.dropbox.com/s/kkm80yjihyalwes/iati_dump.zip?dl=1 -O data.zip
unzip -q data.zip
rm -rf metadata data.zip

cd helpers
# Update codelist mapping, codelists and schemas
./get_codelist_mapping.sh
./get_codelists.sh
./get_schemas.sh
# Build a JSON file of metadata for each CKAN publisher, and for each dataset published.
# This is based on the data from the CKAN API
wget "http://dashboard.iatistandard.org/stats/ckan.json" -O ckan.json
cd ..

# TODO: this needs a bit of reshaping
wget https://www.dropbox.com/s/6a3wggckhbb9nla/metadata.json?dl=1 -O gitdate.json

export GITOUT_DIR="stats-blacklist"
rm -rf out
mkdir -p $GITOUT_DIR/logs
mkdir -p $GITOUT_DIR/commits
mkdir -p $GITOUT_DIR/gitaggregate
mkdir -p $GITOUT_DIR/gitaggregate-dated
cp helpers/ckan.json $GITOUT_DIR
cp gitdate.json $GITOUT_DIR

python calculate_stats.py --stats-module stats.activity_future_transaction_blacklist loop || exit 1
python calculate_stats.py --stats-module stats.activity_future_transaction_blacklist aggregate || exit 1
python calculate_stats.py --stats-module stats.activity_future_transaction_blacklist invert || exit 1
mv out $GITOUT_DIR/current
python statsrunner/gitaggregate.py
python statsrunner/gitaggregate.py dated
python statsrunner/gitaggregate-publisher.py
python statsrunner/gitaggregate-publisher.py dated

export GITOUT_DIR="stats-calculated"
rm -rf out
mkdir -p $GITOUT_DIR/logs
mkdir -p $GITOUT_DIR/commits
mkdir -p $GITOUT_DIR/gitaggregate
mkdir -p $GITOUT_DIR/gitaggregate-dated
cp helpers/ckan.json $GITOUT_DIR
cp gitdate.json $GITOUT_DIR

python calculate_stats.py --stats-module stats.dashboard loop || exit 1
python calculate_stats.py --stats-module stats.dashboard aggregate || exit 1
python calculate_stats.py --stats-module stats.dashboard invert || exit 1
mv out $GITOUT_DIR/current
python statsrunner/gitaggregate.py
python statsrunner/gitaggregate.py dated
python statsrunner/gitaggregate-publisher.py
python statsrunner/gitaggregate-publisher.py dated

cd ..
