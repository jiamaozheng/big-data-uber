DROP TABLE IF EXISTS UberAugmented2015Table;
CREATE EXTERNAL TABLE UberAugmented2015Table (
    dispatchBase STRING,
    year INT,
    month INT,
    day INT,
    hour INT,
    minute INT,
    second INT,
    base STRING,
    locationID INT,
    borough STRING,
    zone STRING,
    dateDisplay STRING,
    daySince20150101 INT,
    dayOfWeek INT,
    locationDisplayByBorough STRING,
    locationDisplayByID STRING)
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '\t'
  STORED AS TEXTFILE
  LOCATION '/xinran/augmented-uber-data/uber2015augmented';


DROP TABLE IF EXISTS UberPrecomputing2015Table;
CREATE EXTERNAL TABLE UberPrecomputing2015Table (
    locationDisplayByBorough STRING,
    yearMonth INT,
    hour INT,
    dayOfWeek INT,
    countYearMonthHourDayofweek INT)
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '\t'
  STORED AS TEXTFILE
  LOCATION '/xinran/precomputing-uber-data/uber2015precomputing';


INSERT INTO TABLE UberPrecomputing2015Table

SELECT locationDisplayByBorough, CONCAT(year, LPAD(month, 2, '0')) AS yearMonth, hour, dayOfWeek, COUNT(*) AS countYearMonthHourDayofweek
FROM UberAugmented2015Table
GROUP BY locationDisplayByBorough, year, month, hour, dayOfWeek;


