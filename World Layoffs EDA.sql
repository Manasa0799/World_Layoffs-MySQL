-- EDA Project Portfolio

-- BASIC EXPLORATION -------------------------------------------------------------------------------------------

SELECT *
FROM layoffs_staging2;


-- 1. What is the maximum of total layoffs?
-- 12000
-- Identifies the highest number of layoffs in a single event.

SELECT MAX(total_laid_off)
FROM layoffs_staging2;		


-- 2. What is the range of layoff percentages across all companies during this period?
-- Maximum percentage laid off is 1 
-- Shows the range of layoffs as a percentage of total employees.

SELECT MAX(percentage_laid_off)
FROM layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;


-- 3. Which companies completely shut down by laying off 100% of their workforce?
-- Identifies companies that completely laid off their staff.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;


-- 4. How many companies were closed during the layoff?
-- 232 , these are mostly startups it looks like who all went out of business during this time.

SELECT percentage_laid_off, COUNT(company)
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY percentage_laid_off;


-- 5. Among companies that laid off 100% of their workforce, which raised the most funds before shutting down?
-- Lists companies that shut down, sorted by the funds they had raised.
-- Britishvolt with 2400 funds raised.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- 6. Which company had the highest number of layoffs in a single event between 2020 and 2023?
-- Google : 12000, 2023-01-20

SELECT company, total_laid_off, date
FROM layoffs_staging2
WHERE YEAR(`date`) BETWEEN 2020 AND 2023
ORDER BY total_laid_off DESC
LIMIT 1;

-- GROUPED ANALYSIS -------------------------------------------------------------------------------------------------------

-- 7. What are the Top 5 companies with single-day layoffs?
-- Finds companies with the largest layoffs in a single day.
/*
Google		12000
Meta		11000
Amazon		10000
Microsoft	10000
Ericsson	8500
*/
SELECT company, total_laid_off
FROM layoffs_staging
ORDER BY 2 DESC
LIMIT 5;


-- 8. Which companies had the highest total layoffs from 2020 to 2023?
-- Aggregates layoffs by company and finds the top 10 with the most.
/*
Amazon		36300
Google		24000
Meta		22000
Salesforce	20180
Microsoft	20000
Philips		20000
Ericsson	17000
Uber		15170
Dell		13300
Booking.com	9202
*/
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company 
ORDER BY 2 DESC
LIMIT 10;


-- 9. Which cities or locations experienced the highest number of layoffs during this period?
-- These queries group layoffs by location to show which places were most impacted.
/*
SF Bay Area		251262
Seattle			69486
New York City	58728
Bengaluru		43574
Amsterdam		34280
Stockholm		22434
Boston			21570
Sao Paulo		18162
Austin			17960
Chicago			12838
*/
SELECT location, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;


-- 10. Which countries were most affected by layoffs from 2020 to 2023?
/*
United States	513118
India			71986
Netherlands		34440
Sweden			22528
Brazil			20782
Germany			17402
United Kingdom	12796
Canada			12638
Singapore		11990
China			11810
*/
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;


-- 11. How did layoffs trend across different industries from 2020 to 2023? Which industries were hit the hardest?
/*
Consumer		90364
Retail			87226
Other			72578
Transportation	67496
Finance			56688
Healthcare		51906
Food			45710
Real Estate		35130
Travel			34318
Hardware		27656
*/
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
LIMIT 10;


-- 12. At what stage (startup, growth, etc.) were most companies when they laid off staff?
-- Aggregates layoffs by company growth stage (startup, growth, mature, etc.)

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC
LIMIT 10;


-- 13. How did the number of layoffs change from year to year between 2020 and 2023?
-- Trends layoffs by year to see shifts over time or within sectors.
/*
2020	161996
2021	31646
2022	321322
2023	251354
*/
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date) 
ORDER BY 1 ASC;


-- ADVANCED QUERIES ----------------------------------------------------------------------------------------------------------

-- 14. Which companies had the most layoffs each year from 2020 to 2023?
-- Use window functions and CTEs (Common Table Expressions) to show the top companies by layoffs for each year.
/*
Uber		2020	15050	1
Booking.com	2020	8750	2
Groupon		2020	5600	3
Bytedance	2021	7200	1
Katerra		2021	4868	2
Zillow		2021	4000	3
Meta		2022	22000	1
Amazon		2022	20300	2
Cisco		2022	8200	3
Google		2023	24000	1
Microsoft	2023	20000	2
Ericsson	2023	17000	3
*/
WITH Company_Year AS
(
SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(date)
),
Company_Rank_Year AS 
(
SELECT company, years, total_layoffs,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_layoffs DESC) AS ranking
FROM Company_Year
)
SELECT company, years, total_layoffs, ranking
FROM Company_Rank_Year
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_layoffs DESC;


-- 15. What is the rolling total of layoffs by month from 2020 to 2023?
-- Computes the cumulative total of layoffs over time, providing insight into how layoffs have trended monthly.

-- Rolling Total of Layoffs Per Month

SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;






