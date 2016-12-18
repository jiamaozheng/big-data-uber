UBER_PRECOMPUTING_2014 = LOAD '/xinran/precomputing-uber-data/uber2014precomputing' USING PigStorage()
AS (daySince20140401: long, dateDisplay: chararray, dayOfWeek: long, lat: chararray, lon: chararray, countDayLatLon: chararray);

UBER_PRECOMPUTING_2014_CONCAT = FOREACH UBER_PRECOMPUTING_2014
GENERATE daySince20140401, dateDisplay, dayOfWeek, CONCAT(lat, ',', lon, ',', countDayLatLon) AS latLonCount: chararray;

UBER_PRECOMPUTING_2014_GROUPED = GROUP UBER_PRECOMPUTING_2014_CONCAT BY (daySince20140401, dateDisplay, dayOfWeek);

UBER_PRECOMPUTING_2014_BAG = FOREACH UBER_PRECOMPUTING_2014_GROUPED
GENERATE group.daySince20140401, group.dateDisplay, group.dayOfWeek, UBER_PRECOMPUTING_2014_CONCAT.latLonCount AS uberBag;

UBER_PRECOMPUTING_2014_GUI = FOREACH UBER_PRECOMPUTING_2014_BAG
GENERATE daySince20140401, dateDisplay, dayOfWeek, BagToString(uberBag, ',') AS guiData: chararray;

STORE UBER_PRECOMPUTING_2014_GUI INTO 'hbase://xinran_uber_2014_map_batch'
USING org.apache.pig.backend.hadoop.hbase.HBaseStorage('uber2014:dateDisplay, uber2014:dayOfWeek, uber2014:guiData');


