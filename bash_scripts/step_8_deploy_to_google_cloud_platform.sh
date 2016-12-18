#!/bin/bash

# As the mpcs53013 cluster on Google Cloud Platform has different configuration compared to the local machine,
# minor modification is needed in order to deploy this project to Google Cloud Platform and make it publicly accessible.

# From
my $hbase = HBase::JSONRest->new(host => 'localhost:8080');
# To
my $hbase = HBase::JSONRest->new(host => 'hdp-m.c.mpcs53013-2016.internal:2056');


# From
$connection = Kafka::Connection->new( host => 'localhost', port => 9092 );
# To
$connection = Kafka::Connection->new( host => 'hdp-m.c.mpcs53013-2016.internal', port => 6667 );


# From
beeline -u jdbc:hive2://localhost:10000 ......
# To
beeline -u jdbc:hive2://hdp-w-0.c.mpcs53013-2016.internal:10000 ......


# From
storm jar uber-xinranUberSpeedLayer-0.0.1-SNAPSHOT.jar ......
# To
storm jar -c zookeeper.znode.parent=/hbase-unsecure uber-xinranUberSpeedLayer-0.0.1-SNAPSHOT.jar ......


# The following commands are especially useful when working with Google Cloud Platform
gcloud compute ssh hdp-m
gcloud compute ssh webserver
gcloud compute copy-files /xxx/xxx hdp-m:/xxx/xxx
gcloud compute copy-files /xxx/xxx webserver:/xxx/xxx


# Finally, this project has been deployed to Google Cloud Platform and can be publicly accessed at
http://104.197.248.161/xinran/xinran_uber_2014_map.html
http://104.197.248.161/xinran/xinran_uber_2015_plot.html


