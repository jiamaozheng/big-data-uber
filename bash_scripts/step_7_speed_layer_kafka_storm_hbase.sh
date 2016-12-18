#!/bin/bash


# Prepare the Perl file to demonstrate the speed layer
sudo cp web_server_usr_lib_cgi-bin/submit_uber_mock_data.pl /usr/lib/cgi-bin/xinran/
sudo chmod a+rx /usr/lib/cgi-bin/xinran/submit_uber_mock_data.pl


# Prepare Kafka topic
# Create the topic
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic xinran-uber-events
# Make sure the topic has been created as expected
kafka-topics.sh --list --zookeeper localhost:2181
# Show the messages in the topic
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic xinran-uber-events --from-beginning --zookeeper localhost:2181


# Prepare HBase table
# First, run hbase shell
hbase shell
# Then, in hbase shell, run the following commands
disable 'xinran_uber_2015_plot_speed'
drop 'xinran_uber_2015_plot_speed'
create 'xinran_uber_2015_plot_speed', 'uber2015'


# Run the Storm topology
# List the status of Storm topologies
storm list
# Kill a running topology if need to
storm kill XinranUberTopology
# Run a new topology from a jar file
storm jar uber-xinranUberSpeedLayer-0.0.1-SNAPSHOT.jar edu.uchicago.mpcs53013.xinranUberSpeedLayer.XinranUberTopology XinranUberTopology


# Check if the Perl file is running as expected
# To add new records
#     http://localhost/cgi-bin/xinran/submit_uber_mock_data.pl?location=Bronx, Bronxdale&year=2015&month=12&day=13&hour=3&minute=28&second=8&pickup=100
# To reset existing records
#     http://localhost/cgi-bin/xinran/submit_uber_mock_data.pl?location=Bronx, Bronxdale&year=-1&month=-1&day=-1&hour=-1&minute=-1&second=-1&pickup=-1


