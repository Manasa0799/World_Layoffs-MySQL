-- Data Cleaning Project - MySQL

SELECT *
FROM layoffs;

-- Inorder to perform Data Cleaning creating a table for staging so we can modify and remove the unwanted data for cleaning

CREATE TABLE layoffs_staging
LIKE layoffs;

-- Insert the values of raw data

INSERT layoffs_staging
SELECT *
FROM layoffs; 

SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

--  Steps for Cleaning Data
-- 1. Check for duplicates and remove any
-- 2. Standardize data and fix errors
-- 3. Look at null values and blank values 
-- 4. Remove any columns and rows that are not necessary


-- 1. Remove Duplicates ----------------------------------------------------------------------------------------

-- Assigning row_number to find duplicate values

SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Using CTE for subquering to find duplicate values having rows more than 1

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Check and conform the duplicate values

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Creating another table that includes row_num column so we can filter and remove duplicates based on the column and can delete it later

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Check if table is created and Insert the values from layoffs_staging

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging; 

-- Delete all the duplicate values having row number more than 1

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- 2. Standardizing Data -------------------------------------------------------------------------------------

-- Look for alingnment and spaces. Use trim to correct them
-- Look for blank cells
-- Modify datatypes if required - date column
-- Look for names that has different variations
-- Look for names ending with period '.'
-- Check null values 

-- Triming spaces and fixing alignment

SELECT DISTINCT (TRIM(company))
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Update into the table

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Check for unique industries and identify variant names

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Crypto has 2 different names as Crypto Currency and CryptoCurrency, update them

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Check for other columns as well

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- I can see United States poped twice, fix the '.'

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

-- Change the Datatype for Date column
-- We are using string to date funtion and use date format in MySQL 

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify Datatype of Date column

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Remove all blank values and Check for Null Values -------------------------------------------------------

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- let's take a look at these

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- nothing wrong here

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'airbnb%';

-- We can see 2 companies repeated twice with null values in different columns
-- And 2 companies with null values in industry column

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- now if we check those are all null

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- now we need to populate those nulls if possible

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Change all the blank values to null values 

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT DISTINCT industry 
FROM layoffs_staging2;

-- 4. Remove any columns and rows we need to -----------------------------------------------------------

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
-- total_laid_off and percentage_laid_off are all null values i.e., there was no layoffs in those companies

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- Remove the unwaned column row_num

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;







