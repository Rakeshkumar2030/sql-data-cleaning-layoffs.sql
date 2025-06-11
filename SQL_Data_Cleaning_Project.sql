-- ========================================
-- Step 1: Create Staging Table
-- ========================================

CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- ========================================
-- Step 2: Identify Duplicate Records
-- ========================================

SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, date
  ) AS row_num
FROM layoffs_staging;

-- Check duplicate records
WITH duplicate_cte AS (
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage,
      country, funds_raised_millions
    ) AS row_num
  FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- ========================================
-- Step 3: Prepare Table for Deleting Duplicates
-- ========================================

CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  date TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

INSERT INTO layoffs_staging2
SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage,
    country, funds_raised_millions
  ) AS row_num
FROM layoffs_staging;

-- Delete duplicate rows
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- ========================================
-- Step 4: Standardize Text Columns (Trim & Clean)
-- ========================================

-- Trim company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize 'Crypto' industry values
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean trailing dot in country
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- ========================================
-- Step 5: Convert Date Format (from text to DATE)
-- ========================================

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- ========================================
-- Step 6: Handle Nulls and Blank Values
-- ========================================

-- Replace blank strings with NULLs
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill NULL industry from matching company with known industry
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Delete rows with no layoff data
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- ========================================
-- Step 7: Final Cleanup
-- ========================================

-- Drop helper column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ========================================
-- Step 8: Summary Statistics
-- ========================================

SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT company) AS unique_companies,
  COUNT(*) - COUNT(total_laid_off) AS null_layoffs,
  COUNT(*) - COUNT(percentage_laid_off) AS null_percentage
FROM layoffs_staging2;

-- ========================================
-- Step 9: Bonus Analysis Queries (Optional for GitHub)
-- ========================================

-- Total layoffs by year
SELECT 
  YEAR(date) AS year,
  SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year;

-- Top 5 companies with most layoffs
SELECT 
  company,
  SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 5;

-- Layoffs by industry
SELECT 
  industry,
  SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Countries with highest layoffs
SELECT 
  country,
  SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;
