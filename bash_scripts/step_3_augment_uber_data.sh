#!/bin/bash

# This step adds several columns to both uber 2014 and 2015 data,
# which will be used by later processing steps.

# Remove existing output files, if any
hdfs dfs -rm -R /xinran/augmented-uber-data

# Add several computed columns to uber 2014 data
pig augment_uber_data_2014.pig

# Add several computed columns to uber 2015 data
pig augment_uber_data_2015.pig

# Check if the output files are as expected
hdfs dfs -ls -R /xinran/augmented-uber-data


# The result should look like
# ......          0 ....../augmented-uber-data
# ......          0 ....../augmented-uber-data/uber2014augmented
# ......          0 ....../augmented-uber-data/uber2014augmented/_SUCCESS
# ......   97108789 ....../augmented-uber-data/uber2014augmented/part-m-00000
# ......   97050243 ....../augmented-uber-data/uber2014augmented/part-m-00001
# ......   61206415 ....../augmented-uber-data/uber2014augmented/part-m-00002
# ......          0 ....../augmented-uber-data/uber2015augmented
# ......          0 ....../augmented-uber-data/uber2015augmented/_SUCCESS
# ...... 1015292947 ....../augmented-uber-data/uber2015augmented/part-r-00000
# ......  918306927 ....../augmented-uber-data/uber2015augmented/part-r-00001


