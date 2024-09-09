-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates

-- Date was not in the correct format for MySQL.
UPDATE layoffs
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` LIKE '%/%/%';  -- Apply conversion only to dates in the MM/DD/YYYY format

-- When I imported the data some values were 'None' but they actually mean NULL.
UPDATE layoffs
SET total_laid_off = NULL
WHERE total_laid_off = 'none';

UPDATE layoffs
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'none';

UPDATE layoffs
SET `date` = NULL
WHERE `date` = 'none';

ALTER TABLE layoffs
MODIFY COLUMN total_laid_off INT,
MODIFY COLUMN `date` date,
MODIFY COLUMN funds_raised_millions INT;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- OPTION 1
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

-- OPTION 2

-- Copy the clipboard create statement 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Now there is no duplicated rows.


-- 2. Standardizing Data

-- Update table to trim spaces
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT industry
FROM layoffs_staging2
ORDER BY 1;

-- I want to make sure columns that reference the same thing have the same name.
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Making sure syntax is correct.

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- 3. Null and Blank Values
SELECT *
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'None'
WHERE industry = '';

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry = 'None'
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry = 'None' OR t1.industry = '')
AND t2.industry != 'None';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry = 'None' OR t1.industry = '')
AND t2.industry != 'None';

SELECT *
FROM layoffs_staging2;

-- 4. Remove unnecessary columns and rows.

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'None';

ALTER TABLE layoffs_staging2
MODIFY COLUMN percentage_laid_off INT;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


