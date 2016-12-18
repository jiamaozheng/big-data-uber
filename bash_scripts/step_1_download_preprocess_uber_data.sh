#!/bin/bash

# Data source:
# https://github.com/fivethirtyeight/uber-tlc-foil-response

# Input and output path base
input="https://github.com/fivethirtyeight/uber-tlc-foil-response/raw/master/uber-trip-data/"
output="uber_raw_data/"

# Create the output directory
mkdir "$output"

# Uber pickup data from 2014/04 to 2014/09 (delete the first line of each .csv file)
wget "${input}uber-raw-data-apr14.csv" -O tempfile && tail -n +2 tempfile > "${output}uber201404.csv"
wget "${input}uber-raw-data-may14.csv" -O tempfile && tail -n +2 tempfile > "${output}uber201405.csv"
wget "${input}uber-raw-data-jun14.csv" -O tempfile && tail -n +2 tempfile > "${output}uber201406.csv"
wget "${input}uber-raw-data-jul14.csv" -O tempfile && tail -n +2 tempfile > "${output}uber201407.csv"
wget "${input}uber-raw-data-aug14.csv" -O tempfile && tail -n +2 tempfile > "${output}uber201408.csv"
wget "${input}uber-raw-data-sep14.csv" -O tempfile && tail -n +2 tempfile > "${output}uber201409.csv"

# Uber pickup data from 2015/01 to 2015/06 (unzip and delete the first and last line of the .csv file)
wget "${input}uber-raw-data-janjune-15.csv.zip" -O tempfile && unzip -p tempfile | tail -n +2 | head -n -1 > "${output}uber2015_01_to_06.csv"
# Taxi zone lookup table, i.e. from Location ID to Borough and Zone (repair the newline character and delete the first line of the .csv file)
wget "${input}taxi-zone-lookup.csv" -O tempfile && cat tempfile | tr '\r' '\n' | tail -n +2 > "${output}uber2015_lookup.csv"

# Delete the temporary file
rm -f tempfile


# The result should look like
# uber_raw_data/
# ├── uber201404.csv
# ├── uber201405.csv
# ├── uber201406.csv
# ├── uber201407.csv
# ├── uber201408.csv
# ├── uber201409.csv
# ├── uber2015_01_to_06.csv
# └── uber2015_lookup.csv


