-- File Name: Exploratory Data Analysis.sql
-- Author: Sebastian Duarte
-- Date: August 2024
-- Description: SQL scripts for an exploratory data analysis on world company layoffs.

-- First thing I want to do is take a look at the table I will be analyzing.

SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; -- This max number of employees laid off was 12000, which corresponds to the 100% of that company.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1; -- These are the companies that laid off a 100% of their employees.


SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC; -- Organized by the total layoffs.

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; -- Per company, this is the amount of employees laid off.

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2; -- Layoffs started in 2020 and continues until 2023.


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC; -- Assumption: The industry that was most affected by COVID was the Consumer industry. 


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC; -- Assumption: The country that was most affected by COVID was United States.

SELECT *
FROM layoffs_staging2;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; -- The amount laid off in 2023 will be the highest, taking into account that we only have 3 months of data from 2023 and it is the second highest year.


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC; -- Depending on the stage the company was at, the second column shows the total of employees laid off.


WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total; -- As we can see, 2022 was the year when the number of laid off employees started to grow up exponentially.

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; -- Total number of layoffs per company per year, sorted in descending order of the total layoffs.


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
-- Per year, these are the top 5 companies that had the most amount of layoffs.
