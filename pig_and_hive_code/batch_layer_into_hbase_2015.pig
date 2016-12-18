UBER_PRECOMPUTING_2015 = LOAD '/xinran/precomputing-uber-data/uber2015precomputing' USING PigStorage()
AS (locationDisplayByBorough: chararray, yearMonth: chararray, hour: chararray, 
    dayOfWeek: chararray, countYearMonthHourDayofweek: chararray);

UBER_PRECOMPUTING_2015_CONCAT = FOREACH UBER_PRECOMPUTING_2015
GENERATE CONCAT(locationDisplayByBorough, '+', yearMonth) AS key: chararray,
         CONCAT(dayOfWeek, ',', hour, ',', countYearMonthHourDayofweek) AS valueCell: chararray;

UBER_PRECOMPUTING_2015_GROUPED = GROUP UBER_PRECOMPUTING_2015_CONCAT BY key;

UBER_PRECOMPUTING_2015_BAG = FOREACH UBER_PRECOMPUTING_2015_GROUPED
GENERATE group AS key: chararray, UBER_PRECOMPUTING_2015_CONCAT.valueCell AS uberBag;

UBER_PRECOMPUTING_2015_GUI = FOREACH UBER_PRECOMPUTING_2015_BAG
GENERATE key, BagToString(uberBag, '|') AS guiData: chararray;

STORE UBER_PRECOMPUTING_2015_GUI INTO 'hbase://xinran_uber_2015_plot_batch'
USING org.apache.pig.backend.hadoop.hbase.HBaseStorage('uber2015:guiData');


