#!/bin/bash

# Remove existing output files, if any
hdfs dfs -rm -R /xinran/precomputing-uber-data

# Run the Hive sql code
# In terminal 1
hiveserver2
# In terminal 2
beeline -u jdbc:hive2://localhost:10000 -n mpcs53013 -p hadoop -f precompute_uber_intermediate_2014.hql
beeline -u jdbc:hive2://localhost:10000 -n mpcs53013 -p hadoop -f precompute_uber_intermediate_2015.hql

# Check if the output files are as expected
hdfs dfs -ls -R /xinran/precomputing-uber-data


# The result should look like
# ......          0 ....../uber2014precomputing
# ......   35966514 ....../uber2014precomputing/000000_0
# ......          0 ....../uber2015precomputing
# ......    1112155 ....../uber2015precomputing/000000_0
# ......    1111470 ....../uber2015precomputing/000001_0
# ......    1111892 ....../uber2015precomputing/000002_0
# ......    1115229 ....../uber2015precomputing/000003_0
# ......    1114518 ....../uber2015precomputing/000004_0
# ......    1113344 ....../uber2015precomputing/000005_0
# ......    1116278 ....../uber2015precomputing/000006_0
# ......    1114806 ....../uber2015precomputing/000007_0


