-- ============================================================
-- EXPLORATORY DATA ANALYSIS: GLOBAL LAYOFFS DATASET
-- Goal: Analyze trends, patterns, and insights from cleaned data
-- ============================================================


-- ============================================================
-- STEP 1: DATA OVERVIEW
-- ============================================================

-- Preview dataset
SELECT *
FROM layoffs_staging2;


-- ============================================================
-- STEP 2: MAX VALUES ANALYSIS
-- ============================================================

-- Find maximum layoffs and maximum percentage laid off
SELECT 
    MAX(total_laid_off) AS max_layoffs,
    MAX(percentage_laid_off) AS max_percentage
FROM layoffs_staging2;

-- Identify companies where 100% employees were laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- ============================================================
-- STEP 3: LAYOFFS BY COUNTRY
-- ============================================================

-- Total layoffs grouped by country
SELECT 
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;


-- ============================================================
-- STEP 4: DATE RANGE ANALYSIS
-- ============================================================

-- Find earliest and latest layoff dates
SELECT 
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_staging2;


-- ============================================================
-- STEP 5: LAYOFFS BY YEAR
-- ============================================================

-- Total layoffs per year
SELECT 
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY year
ORDER BY year DESC;


-- ============================================================
-- STEP 6: LAYOFFS BY COMPANY STAGE
-- ============================================================

-- Analyze layoffs based on funding stage
SELECT 
    stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;


-- ============================================================
-- STEP 7: AVERAGE LAYOFF PERCENTAGE BY COMPANY
-- ============================================================

-- Identify companies with highest average layoffs percentage
SELECT 
    company,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY avg_percentage_laid_off DESC;


-- ============================================================
-- STEP 8: COMPANY LAYOFFS BY YEAR
-- ============================================================

-- Total layoffs per company per year
SELECT 
    company,
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, year
ORDER BY total_layoffs DESC;


-- ============================================================
-- STEP 9: TOP 5 COMPANIES BY LAYOFFS PER YEAR
-- ============================================================

-- Step 1: Aggregate layoffs by company and year
WITH company_year AS (
    SELECT 
        company, 
        YEAR(`date`) AS years, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, years
),

-- Step 2: Rank companies within each year
company_year_rank AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY years 
               ORDER BY total_laid_off DESC
           ) AS ranking
    FROM company_year
    WHERE years IS NOT NULL
)

-- Step 3: Select top 5 companies per year
SELECT *
FROM company_year_rank
WHERE ranking <= 5;