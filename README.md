# 🧹 SQL Data Cleaning Project – Layoffs Dataset

## 📌 Project Overview
This project focuses on cleaning a real-world layoffs dataset using SQL, following a tutorial by **Alex The Analyst**.

The dataset includes data on companies, locations, layoffs, funding, and more.  
The main goal was to practice data cleaning techniques using SQL, and prepare the dataset for further analysis or dashboarding.

---

## 🧽 Cleaning Steps Performed
1. Created staging tables to avoid modifying the original table
2. Removed duplicate rows using `ROW_NUMBER()` and `DELETE`
3. Standardized company and country names using `TRIM()`
4. Replaced inconsistent `industry` values (e.g., "Crypto", "Crypto - Blockchain")
5. Converted `date` column from string to proper `DATE` format using `STR_TO_DATE()`
6. Handled null and blank values with `JOIN` and `UPDATE`
7. Removed records with no meaningful data (e.g., layoffs = NULL)
8. Generated summary queries and basic analysis

---

## 🛠 Tools Used
- MySQL Workbench
- SQL
- GitHub

---

## 📁 Files Included
- `SQL_Data_Cleaning_Project.sql` – Full SQL script used for data cleaning
- `layoffs_cleaned_data.csv` – Final cleaned dataset exported from MySQL
- `README.md` – Project explanation and documentation

---

## 📊 Bonus Analysis Queries
```sql
-- Total layoffs by year
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date);

-- Top 5 companies with most layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 5;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;
```

🎓 Credits

This project is based on the [SQL Data Cleaning Project](https://www.youtube.com/watch?v=7NBt0V8ebGk) tutorial by **Alex The Analyst**.  
I followed the video to practice real-world SQL data cleaning skills and added my own structuring, summary analysis, and GitHub formatting.

---


