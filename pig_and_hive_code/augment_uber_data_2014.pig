REGISTER /usr/local/mpcs53013/elephant-bird-core-4.14.jar;
REGISTER /usr/local/mpcs53013/elephant-bird-pig-4.14.jar;
REGISTER /usr/local/mpcs53013/elephant-bird-hadoop-compat-4.14.jar;
REGISTER /usr/local/mpcs53013/libthrift-0.9.0.jar;
REGISTER /usr/local/mpcs53013/piggybank-0.15.0.jar;
REGISTER /home/mpcs53013/workspace/uberDataIngest/target/uber-uberDataIngest-0.0.1-SNAPSHOT.jar;

DEFINE WSThriftBytesToTuple com.twitter.elephantbird.pig.piggybank.ThriftBytesToTuple('edu.uchicago.mpcs53013.uberDataIngest.UberRecord2014');

RAW_DATA = LOAD '/xinran/input-uber-data/uber2014' USING org.apache.pig.piggybank.storage.SequenceFileLoader() AS (key: long, value: bytearray);

UBER_RECORD_2014_RAW = FOREACH RAW_DATA GENERATE FLATTEN(WSThriftBytesToTuple(value));

UBER_RECORD_2014_DISPLAY = FOREACH UBER_RECORD_2014_RAW GENERATE *, CONCAT((chararray)year, '-', (chararray)month, '-', (chararray)day) AS dateDisplay: chararray;

UBER_RECORD_2014_DAYSINCE = FOREACH UBER_RECORD_2014_DISPLAY GENERATE *, DaysBetween(ToDate(dateDisplay, 'yyyy-M-d', 'UTC'), ToDate('2014-4-1', 'yyyy-M-d', 'UTC')) + 1L AS daySince20140401: long;

UBER_RECORD_2014_AUGMENTED = FOREACH UBER_RECORD_2014_DAYSINCE GENERATE *, (daySince20140401 + 1L) % 7 AS dayOfWeek: long;

STORE UBER_RECORD_2014_AUGMENTED INTO '/xinran/augmented-uber-data/uber2014augmented' USING PigStorage();


