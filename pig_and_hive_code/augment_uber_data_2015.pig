REGISTER /usr/local/mpcs53013/elephant-bird-core-4.14.jar;
REGISTER /usr/local/mpcs53013/elephant-bird-pig-4.14.jar;
REGISTER /usr/local/mpcs53013/elephant-bird-hadoop-compat-4.14.jar;
REGISTER /usr/local/mpcs53013/libthrift-0.9.0.jar;
REGISTER /usr/local/mpcs53013/piggybank-0.15.0.jar;
REGISTER /home/mpcs53013/workspace/uberDataIngest/target/uber-uberDataIngest-0.0.1-SNAPSHOT.jar;

DEFINE WSThriftBytesToTuple com.twitter.elephantbird.pig.piggybank.ThriftBytesToTuple('edu.uchicago.mpcs53013.uberDataIngest.UberRecord2015');

RAW_DATA = LOAD '/xinran/input-uber-data/uber2015' USING org.apache.pig.piggybank.storage.SequenceFileLoader() AS (key: long, value: bytearray);

UBER_RECORD_2015_RAW = FOREACH RAW_DATA GENERATE FLATTEN(WSThriftBytesToTuple(value));

UBER_RECORD_2015_DISPLAY = FOREACH UBER_RECORD_2015_RAW GENERATE *, CONCAT((chararray)year, '-', (chararray)month, '-', (chararray)day) AS dateDisplay: chararray;

UBER_RECORD_2015_DAYSINCE = FOREACH UBER_RECORD_2015_DISPLAY GENERATE *, DaysBetween(ToDate(dateDisplay, 'yyyy-M-d', 'UTC'), ToDate('2015-1-1', 'yyyy-M-d', 'UTC')) + 1L AS daySince20150101: long;

UBER_RECORD_2015_AUGMENTED = FOREACH UBER_RECORD_2015_DAYSINCE GENERATE *, (daySince20150101 + 3L) % 7 AS dayOfWeek: long;

LOOKUP_TABLE = LOAD '/xinran/input-uber-data/uber2015_lookup.csv' USING org.apache.pig.piggybank.storage.CSVLoader() AS (locationIDcsv: long, borough: chararray, zone: chararray);

UBER_RECORD_2015_JOINED_RAW = JOIN UBER_RECORD_2015_AUGMENTED BY locationID, LOOKUP_TABLE BY locationIDcsv;

UBER_RECORD_2015_JOINED = FOREACH UBER_RECORD_2015_JOINED_RAW GENERATE dispatchBase, year, month, day, hour, minute, second, base, locationID, borough, zone, dateDisplay, daySince20150101, dayOfWeek;

UBER_RECORD_2015_LOCATION_BY_BOROUGH = FOREACH UBER_RECORD_2015_JOINED GENERATE *, CONCAT(borough, ', ', zone) AS locationDisplayByBorough: chararray;

UBER_RECORD_2015_LOCATION_BY_ID = FOREACH UBER_RECORD_2015_LOCATION_BY_BOROUGH GENERATE *, CONCAT(SPRINTF('%03d', locationID), '. ', locationDisplayByBorough) AS locationDisplayByID: chararray;

STORE UBER_RECORD_2015_LOCATION_BY_ID INTO '/xinran/augmented-uber-data/uber2015augmented' USING PigStorage();


