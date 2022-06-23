SELECT err.*
FROM trip_hist_err as err
    LEFT JOIN trip_hist as t ON err.trip_id = t.trip_id
WHERE t.trip_id IS NULL
LIMIT 5;

-- Alter the lost trip history entries to have datetime COLUMNS
SELECT start_date, end_date -- inspect the string format for datetime
FROM trip_hist_err;

-- 1) verify using simulated output, SELECT
SELECT CONCAT(SUBSTRING(start_date, 7, 4),'-', SUBSTRING(start_date, 1, 2),'-', SUBSTRING(start_date, 4, 2), SUBSTRING(start_date, 11))  as start_date
FROM trip_hist_err
WHERE start_date LIKE '%/%';-- original: mm/dd/YYYY HH:MM target: YYYY-mm-dd HH:MM:SS

-- 2) commit the changes to the database, UPDATE
UPDATE trip_hist_err
SET start_date = CONCAT(SUBSTRING(start_date, 7, 4),'-', SUBSTRING(start_date, 1, 2),'-', SUBSTRING(start_date, 4, 2), SUBSTRING(start_date, 11))
WHERE start_date LIKE '%/%';

-- 3) change the column type, MODIFY
ALTER TABLE trip_hist_err
MODIFY COLUMN start_date DATETIME;

-- Repeat with end_date
-- 1) verify using simulated output, SELECT
SELECT CONCAT(SUBSTRING(end_date, 7, 4),'-', SUBSTRING(end_date, 1, 2),'-', SUBSTRING(end_date, 4, 2), SUBSTRING(end_date, 11))  as end_date
FROM trip_hist_err
WHERE end_date LIKE '%/%';-- original: mm/dd/YYYY HH:MM target: YYYY-mm-dd HH:MM:SS

-- 2) commit the changes to the database, UPDATE
UPDATE trip_hist_err
SET end_date = CONCAT(SUBSTRING(end_date, 7, 4),'-', SUBSTRING(end_date, 1, 2),'-', SUBSTRING(end_date, 4, 2), SUBSTRING(end_date, 11))
WHERE end_date LIKE '%/%';

-- 3) change the column type, MODIFY
ALTER TABLE trip_hist_err
MODIFY COLUMN end_date DATETIME;










