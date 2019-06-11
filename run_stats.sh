set -e

cd IATI-Stats

# remove the output directory
rm -rf data out helpers/IATI-Rulesets helpers/rulesets

# fetch data
wget https://www.dropbox.com/s/kkm80yjihyalwes/iati_dump.zip?dl=1 -O data.zip
unzip -q data.zip
rm -rf metadata data.zip

# Fetch helper data
cd helpers
git clone https://andylolz:${GITHUB_TOKEN}@github.com/IATI/IATI-Rulesets.git
ln -s IATI-Rulesets/rulesets .
./get_codelist_mapping.sh
./get_codelists.sh
./get_schemas.sh
wget "http://dashboard.iatistandard.org/stats/ckan.json" -O ckan.json
wget "https://raw.githubusercontent.com/IATI/IATI-Dashboard/live/registry_id_relationships.csv" -O registry_id_relationships.csv
cd ..

# Calculate some stats
python calculate_stats.py loop
python calculate_stats.py aggregate
python calculate_stats.py invert
# You will now have some JSON stats in the out/ directory

cd ..
