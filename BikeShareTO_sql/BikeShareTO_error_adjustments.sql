-- In one file the delimiter was dropped, all columns are shifted
SELECT *
FROM trip_hist_err
WHERE LENGTH(trip_id) > 8;

-- Shift columns and split trip_id and duration
UPDATE trip_hist_err
SET member_type = bike_id,
    bike_id = end_station_name,
    end_station_name = end_date,
    end_date = end_station_id,
    end_station_id = start_station_name,
    start_station_name = start_date,
    start_date = start_station_id,
    start_station_id = duration,
    duration = SUBSTRING(trip_id, 9),
    trip_id = LEFT(trip_id, 8)
WHERE LENGTH(trip_id) > 8;

-- Alter the lost trip history entries to have datetime COLUMNS
SELECT start_date,
    end_date -- inspect the string format for datetime
FROM trip_hist_err;

-- 1) verify using simulated output, SELECT
SELECT CONCAT(
        SUBSTRING(start_date, 7, 4),
        '-',
        SUBSTRING(start_date, 1, 2),
        '-',
        SUBSTRING(start_date, 4, 2),
        SUBSTRING(start_date, 11)
    ) as start_date
FROM trip_hist_err
WHERE start_date LIKE '%/%';-- original: mm/dd/YYYY HH:MM target: YYYY-mm-dd HH:MM:SS

-- 2) commit the changes to the database, UPDATE
UPDATE trip_hist_err
SET start_date = CONCAT(
        SUBSTRING(start_date, 7, 4),
        '-',
        SUBSTRING(start_date, 1, 2),
        '-',
        SUBSTRING(start_date, 4, 2),
        SUBSTRING(start_date, 11)
    )
WHERE start_date LIKE '%/%';

-- 3) change the column type, MODIFY
ALTER TABLE trip_hist_err
MODIFY COLUMN start_date DATETIME;-- Repeat with end_date

-- 1) verify using simulated output, SELECT
SELECT CONCAT(
        SUBSTRING(end_date, 7, 4),
        '-',
        SUBSTRING(end_date, 1, 2),
        '-',
        SUBSTRING(end_date, 4, 2),
        SUBSTRING(end_date, 11)
    ) as end_date
FROM trip_hist_err
WHERE end_date LIKE '%/%';-- original: mm/dd/YYYY HH:MM target: YYYY-mm-dd HH:MM:SS

-- 2) commit the changes to the database, UPDATE
UPDATE trip_hist_err
SET end_date = CONCAT(
        SUBSTRING(end_date, 7, 4),
        '-',
        SUBSTRING(end_date, 1, 2),
        '-',
        SUBSTRING(end_date, 4, 2),
        SUBSTRING(end_date, 11)
    )
WHERE end_date LIKE '%/%';

-- 3) change the column type, MODIFY
ALTER TABLE trip_hist_err
    MODIFY COLUMN end_date DATETIME; 

-- Combine the problem files to the whole database

-- identify duplicate entries
SELECT trip_id,
    COUNT(trip_id)
FROM trip_hist
GROUP BY trip_id
HAVING COUNT(trip_id) > 1;

-- inspecting duplicates, the duplicates contain NULL information
SELECT DISTINCT *
FROM trip_hist as t1
    INNER JOIN (
        SELECT trip_id,
            COUNT(trip_id)
        FROM trip_hist
        GROUP BY trip_id
        HAVING COUNT(trip_id) > 1
    ) as t2 ON t1.trip_id = t2.trip_id;

-- eliminate duplicate entries, DELETE
DELETE t
FROM trip_hist AS t
WHERE t.end_station_name IS NULL
    and 
        t.trip_id IN (
            SELECT DISTINCT _sub_query.trip_id
            FROM (
                    SELECT trip_id,
                        COUNT(trip_id)
                    FROM trip_hist
                    GROUP BY trip_id
                    HAVING COUNT(trip_id) > 1
                ) _sub_query
        );

ALTER TABLE trip_hist
    MODIFY COLUMN trip_id BIGINT(10) PRIMARY KEY,
    MODIFY COLUMN duration BIGINT(10),
    MODIFY COLUMN start_station_name VARCHAR(50),
    MODIFY COLUMN end_station_name VARCHAR(50),
    MODIFY COLUMN start_station_id INT(6),
    MODIFY COLUMN end_station_id INT(6),
    MODIFY COLUMN bike_id INT(6),
    MODIFY COLUMN member_type VARCHAR(15);

-- now we return to the error table branch

-- identify duplicate entries, no duplicates exist
SELECT trip_id,
    COUNT(trip_id)
FROM trip_hist_err
GROUP BY trip_id
HAVING COUNT(trip_id) > 1;

ALTER TABLE trip_hist_err
    MODIFY COLUMN trip_id BIGINT(10) PRIMARY KEY,
    MODIFY COLUMN duration BIGINT(10),
    MODIFY COLUMN start_station_name VARCHAR(50),
    MODIFY COLUMN end_station_name VARCHAR(50),
    MODIFY COLUMN start_station_id INT(6),
    MODIFY COLUMN end_station_id INT(6),
    MODIFY COLUMN bike_id INT(6),
    MODIFY COLUMN member_type VARCHAR(15);


-- check for duplicates between tables
SELECT t2.trip_id
FROM trip_hist as t1
    JOIN trip_hist_err as t2 ON t1.trip_id = t2.trip_id;

-- finally, append the values from the problem files, INSERT
INSERT INTO trip_hist (
    trip_id,
    duration,
    start_station_id,
    start_date,
    start_station_name,
    end_station_id,
    end_date,
    end_station_name,
    bike_id,
    member_type
)
SELECT trip_id,
    duration,
    start_station_id,
    start_date,
    start_station_name,
    end_station_id,
    end_date,
    end_station_name,
    bike_id,
    member_type
FROM trip_hist_err;


