set -e

cd IATI-Dashboard

# setup the output directory
rm -rf out
git clone --branch gh-pages https://github.com/andylolz/dashboard.git out

# Move generated stats into place
mv ../IATI-Stats/stats-blacklist .
mv ../IATI-Stats/stats-calculated .

# Fetch some extra data from github and github gists
./fetch_data.sh

python plots.py
python make_csv.py
python make_html.py

# push output to github
cd out
git add --all
git commit -m "auto"
git push origin gh-pages
cd ..

cd ..
