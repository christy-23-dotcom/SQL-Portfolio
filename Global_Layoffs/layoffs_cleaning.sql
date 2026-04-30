/*
Global Layoffs SQL Data Cleaning Project
Inspired By Alex The Analyst Tutorial
Auther: Christy Susan Philip
*/

CREATE DATABASE world_layoff;
USE world_layoff;
SELECT*FROM layoffs;

-- Created a  staging table for raw data so that the original data remains unchanged

CREATE TABLE layoff_staging LIKE layoffs; 
INSERT INTO layoff_staging SELECT * FROM layoffs;

-- 1.Remove duplicates
/* 
Since the dataset does not have Unique ID column, so ROW_NUMBER() and along with
PARTITION BY is used to assign row number and to identify duplicates
*/
SELECT*FROM layoff_staging;
SELECT*, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off,`date`,country,funds_raised_millions) AS row_num FROM layoff_staging;

-- wrapped ROW_NUMBER() query inside CTE to view the duplicates directly
WITH duplicate_cte AS
(SELECT*, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off,`date`,country,funds_raised_millions) AS row_num FROM layoff_staging
)
SELECT*FROM duplicate_cte WHERE row_num>1;

-- created another staging table to to store cleaned data
CREATE TABLE `layoff_staging2` (
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

-- inserted the data with row numbers
INSERT INTO layoff_staging2
SELECT*, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off,`date`,country,funds_raised_millions) AS row_num FROM layoff_staging;

-- Removed the duplicates having row number more than 1
DELETE FROM layoff_staging2 WHERE row_num>1;

-- 2.Standardise the Data
/*
Checked for whitespaces, formatting issues,date format so that the data remains 
consistant and reliable for analysis
*/
-- removed whitespace for company column
SELECT company,TRIM(company) FROM layoff_staging2;
UPDATE layoff_staging2 SET company =TRIM(company);

-- Standarised naming for all records in industry column
SELECT DISTINCT(industry) FROM layoff_staging2 ORDER BY 1;
SELECT * FROM layoff_staging2 WHERE industry LIKE "Crypto%" ;
UPDATE layoff_staging2 SET industry ="Crypto"
WHERE industry LIKE "Crypto%";

-- removed trailing characters from country
SELECT DISTINCT country ,TRIM(TRAILING '.' FROM country)
FROM layoff_staging2 ORDER BY 1;
UPDATE layoff_staging2 SET country =TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

-- updated proper date format
SELECT `date` FROM layoff_staging2;
UPDATE layoff_staging2 SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');
ALTER TABLE layoff_staging2 MODIFY COLUMN `date` DATE;

-- 3.Null values or blank
-- identified rows with missing value 
SELECT * FROM layoff_staging2 WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- checked for missing rows in industry column
SELECT * FROM layoff_staging2 WHERE industry IS NULL 
OR industry='';
/*
While checking found that each company belong to a single industry
so performed self join on table to find out the missing industries
*/
SELECT t1.industry,t2.industry FROM layoff_staging2 t1 JOIN layoff_staging2 t2 
ON t1.company=t2.company AND t1.location=t2.location
WHERE( t1.industry IS NULL OR t1.industry='') AND t2.industry IS NOT NULL;

-- updated the blanks to null since self join was not working for blanks
UPDATE layoff_staging2 SET industry = NULL
WHERE industry='';

-- performed self join to copy values to the missing industry
UPDATE layoff_staging2 t1 JOIN layoff_staging2 t2 
ON t1.company=t2.company SET t1.industry= t2.industry
WHERE t1.industry IS NULL  AND t2.industry IS NOT NULL;

-- This was left was null since no other records to copy
SELECT* FROM layoff_staging2 WHERE company LIKE "Bally%";

-- 4.Remove any columns
/*
Because the dataset is specifically about global layoffs, records that didn’t 
include any details about the number of employees laid off or the percentage 
laid off had no measurable value. They weren’t describing an actual layoff event, 
just empty entries. To keep the dataset meaningful, I removed those records and only kept 
rows that contribute actual layoff information
*/
SELECT * FROM layoff_staging2 WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE FROM layoff_staging2 WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Finally dropped the helper column row_num 
ALTER TABLE layoff_staging2 DROP COLUMN row_num;
/*
Thanks for looking through my project!
*/