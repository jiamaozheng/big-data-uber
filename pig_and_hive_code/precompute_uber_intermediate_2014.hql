DROP TABLE IF EXISTS UberAugmented2014Table;
CREATE EXTERNAL TABLE UberAugmented2014Table (
    year INT,
    month INT,
    day INT,
    hour INT,
    minute INT,
    second INT,
    lat DOUBLE,
    lon DOUBLE,
    base STRING,
    dateDisplay STRING,
    daySince20140401 INT,
    dayOfWeek INT)
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '\t'
  STORED AS TEXTFILE 
  LOCATION '/xinran/augmented-uber-data/uber2014augmented';


DROP TABLE IF EXISTS UberPrecomputing2014Table;
CREATE EXTERNAL TABLE UberPrecomputing2014Table (
    daySince20140401 INT,
    dateDisplay STRING,
    dayOfWeek INT,
    lat DOUBLE,
    lon DOUBLE,
    countDayLatLon INT)
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '\t'
  STORED AS TEXTFILE
  LOCATION '/xinran/precomputing-uber-data/uber2014precomputing';


INSERT INTO TABLE UberPrecomputing2014Table

SELECT t.daySince20140401, t.dateDisplay, t.dayOfWeek, t.lat, t.lon, COUNT(*) AS countDayLatLon
FROM (
  SELECT daySince20140401, dateDisplay, dayOfWeek, ROUND(lat, 3) AS lat, ROUND(lon, 3) AS lon
  FROM UberAugmented2014Table ) t
GROUP BY t.daySince20140401, t.dateDisplay, t.dayOfWeek, t.lat, t.lon;


