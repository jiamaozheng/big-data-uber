#!/bin/bash


# ##################### The year 2014 #######################


# Prepare HBase table
# First, run hbase shell
hbase shell
# Then, in hbase shell, run the following commands
disable 'xinran_uber_2014_map_batch'
drop 'xinran_uber_2014_map_batch'
create 'xinran_uber_2014_map_batch', 'uber2014'

# Run the Pig code
pig batch_layer_into_hbase_2014.pig

# Check the output results in hbase
# In hbase shell, run the following command
count 'xinran_uber_2014_map_batch'
# The result should be 183 rows


# ##################### The year 2015 #######################


# Prepare HBase table
# First, run hbase shell
hbase shell
# Then, in hbase shell, run the following commands
disable 'xinran_uber_2015_plot_batch'
drop 'xinran_uber_2015_plot_batch'
create 'xinran_uber_2015_plot_batch', 'uber2015'

# Run the Pig code
pig batch_layer_into_hbase_2015.pig

# Check the output results in hbase
# In hbase shell, run the following command
count 'xinran_uber_2015_plot_batch'
# The result should be 1551 rows


