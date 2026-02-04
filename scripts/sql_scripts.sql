# Use the database
USE usedcars;

# Load the CSV file into the table
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/used_cars.csv"
INTO TABLE used_cars_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
-- Process the empty values in columns
(@CarName, @Price, @Mileage, @DealerName, @DealerRating, @Link)
SET 
    CarName = IF(TRIM(@CarName) IN ('', 'none'), NULL, @CarName),
    Price = IF(TRIM(@Price) IN ('', 'none'), NULL, @Price),
    Mileage = IF(TRIM(@Mileage) IN ('', 'none'), NULL, @Mileage),
    DealerName = IF(TRIM(@DealerName) IN ('', 'none'), NULL, @DealerName),
    DealerRating = IF(TRIM(@DealerRating) IN ('', 'none'), NULL, @DealerRating),
    Link = IF(TRIM(@Link) IN ('', 'none'), NULL, @Link);

# Look at used cars data
SELECT *
FROM used_cars_info;

/*

Used Cars Data Wrangling

*/

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE used_cars_staging 
LIKE used_cars_info;

INSERT used_cars_staging 
SELECT * FROM used_cars_info;
 
SELECT *
FROM used_cars_staging;

# Handle missing values
-- Look at nulls and blank values in data
SELECT *
FROM used_cars_staging
WHERE CarName IS NULL OR CarName = '';

-- Drop nulls values
DELETE
FROM used_cars_staging
WHERE CarName IS NULL OR CarName = '';

# Drop Duplicates
-- Look at duplicates in data
SELECT *
FROM (
	SELECT *,
				ROW_NUMBER() OVER(
					PARTITION BY CarName, Price, Mileage, DealerName, DealerRating, Link
                    ORDER BY CarID ASC) AS duplicates_num
	FROM used_cars_staging
) duplicates
WHERE duplicates_num > 1;

-- Drop Duplicates records
WITH drop_duplicates AS(
	SELECT *,
				ROW_NUMBER() OVER(
					PARTITION BY CarName, Price, Mileage, DealerName, DealerRating, Link
                    ORDER BY CarID) AS duplicates_num
	FROM used_cars_staging
)
DELETE
FROM used_cars_staging
WHERE CarID IN(
		SELECT CarID 
        FROM drop_duplicates
        WHERE duplicates_num > 1
);

# Standarize the data
# Convert `Price` and `Mileage` column types for EDA
SELECT Price, Mileage
from used_cars_staging;

-- 1. remove special characters and replace commas from both
UPDATE used_cars_staging
SET Price = REPLACE(TRIM(LEADING '$' FROM Price), ',', ''),
    Mileage = REPLACE(TRIM(TRAILING ' mi.' FROM Mileage), ',', '')
WHERE Price IS NOT NULL AND Mileage IS NOT NULL;

UPDATE used_cars_staging
SET Price = NULL
WHERE Price = 'Not Priced';

-- 2. convert column types
ALTER TABLE used_cars_staging
MODIFY Price int,
MODIFY Mileage int;

# Breaking out CarName into Individual Columns (Year, CarModel)
SELECT CarName
FROM used_cars_staging;

-- Add columns
ALTER TABLE used_cars_staging
ADD COLUMN Year INT AFTER Mileage,
ADD COLUMN CarModel VARCHAR(255) AFTER CarID;

-- Extract Year column
UPDATE used_cars_staging
SET Year = REGEXP_SUBSTR(CarName, '[0-9]{4}');

-- Extract CarModel column
UPDATE used_cars_staging
SET CarModel = TRIM(REGEXP_REPLACE(CarName, '^(Used|Certified)\\s+[0-9]{4}\\s+', ''));

-- Drop 'CarName' column
ALTER TABLE used_cars_staging
DROP COLUMN CarName;

# reshaping CarID
ALTER TABLE used_cars_staging
DROP COLUMN CarID;

# Add CarID column
ALTER TABLE used_cars_staging
ADD COLUMN CarID INT AUTO_INCREMENT PRIMARY KEY FIRST;

     