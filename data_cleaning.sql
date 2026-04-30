-- ============================================================
-- PROJECT: DATA CLEANING USING SQL
-- GOAL: Clean and standardize raw data for further analysis
-- DATASET: Global layoffs
-- ============================================================


-- ============================================================
-- STEP 1: CREATE STAGING TABLE (WORKING COPY)
-- ============================================================

-- Create a duplicate table structure from raw data
CREATE TABLE layoffs_staging LIKE layoffs;

-- Check initial row count (should be 0 before insert)
SELECT COUNT(*) FROM layoffs_staging;

-- Insert raw data into staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- Verify data is loaded
SELECT COUNT(*) FROM layoffs_staging;

-- Preview data
SELECT * FROM layoffs_staging;


-- ============================================================
-- STEP 2: IDENTIFY DUPLICATES
-- ============================================================

-- Use ROW_NUMBER to detect duplicate rows
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
             percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
-- View duplicate rows (row_num > 1)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Example check for a specific company
SELECT *
FROM layoffs_staging
WHERE company = 'casper';


-- ============================================================
-- STEP 3: CREATE SECOND STAGING TABLE WITH ROW NUMBER
-- ============================================================

-- Create a new table to store row numbers for duplicate removal
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

-- Insert data along with row number
INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, 
             percentage_laid_off, `date`, stage, country, funds_raised_millions
ORDER BY company
) AS row_num
FROM layoffs_staging;

-- Remove duplicate rows (keep only row_num = 1)
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Verify cleaned data
SELECT * FROM layoffs_staging2;


-- ============================================================
-- STEP 4: STANDARDIZE TEXT DATA
-- ============================================================

-- Remove leading/trailing spaces from company names
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Check unique industry values
SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY industry;

-- Standardize industry values (e.g., Crypto variations)
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Check unique locations
SELECT DISTINCT location
FROM layoffs_staging2;

-- Clean country column (remove trailing '.')
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- ============================================================
-- STEP 5: FIX DATE FORMAT
-- ============================================================

-- Preview date column
SELECT `date`
FROM layoffs_staging2;

-- Convert text date to proper DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change column type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ============================================================
-- STEP 6: HANDLE MISSING VALUES
-- ============================================================

-- Identify NULL or empty industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- Replace empty strings with NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Check specific companies for missing data
SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Use self-join to fill missing industry values
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Update missing industries using matching company data
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- Verify updates for selected companies
SELECT * 
FROM layoffs_staging2
WHERE company IN ('Airbnb', 'Bally''s Interactive', 'Carvana', 'Juul');


-- ============================================================
-- STEP 7: REMOVE IRRELEVANT ROWS
-- ============================================================

-- Identify rows with no layoff information
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove rows with no useful data
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- ============================================================
-- STEP 8: FINAL CLEANUP
-- ============================================================

-- Remove helper column (no longer needed)
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final cleaned dataset
SELECT * 
FROM layoffs_staging2;