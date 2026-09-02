-- 1a. Create the Database
CREATE DATABASE credit_risk_db;
USE credit_risk_db;

-- 1b. Create the Table (all VARCHAR fields to ensure no data skipping while Import from csv file
DROP TABLE IF EXISTS credit_risk_dataset;
CREATE TABLE credit_risk_dataset (
    person_age VARCHAR(50),
    person_income VARCHAR(50),
    person_home_ownership VARCHAR(50),
    person_emp_length VARCHAR(50),
    loan_intent VARCHAR(50),
    loan_grade VARCHAR(50),
    loan_amnt VARCHAR(50),
    loan_int_rate VARCHAR(50),
    loan_status VARCHAR(50),
    loan_percent_income VARCHAR(50),
    cb_person_default_on_file VARCHAR(50),
    cb_person_cred_hist_length VARCHAR(50)
);

-- 1c. Import the dataset
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/TKS/Desktop/Projects/Credit_Risk_Project/credit_risk_dataset.csv'
INTO TABLE credit_risk_dataset
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- 1d. Create staging table, Fix Data Types and NULL values
DROP TABLE IF EXISTS credit_risk_staging;

CREATE TABLE credit_risk_staging AS
SELECT 
    CAST(NULLIF(person_age, '') AS UNSIGNED) AS person_age,
    CAST(NULLIF(person_income, '') AS UNSIGNED) AS person_income,
    UPPER(TRIM(person_home_ownership)) AS person_home_ownership,
    CAST(NULLIF(person_emp_length, '') AS DOUBLE) AS person_emp_length,
    UPPER(TRIM(loan_intent)) AS loan_intent,
    UPPER(TRIM(loan_grade)) AS loan_grade,
    CAST(NULLIF(loan_amnt, '') AS UNSIGNED) AS loan_amnt,
    CAST(NULLIF(loan_int_rate, '') AS DOUBLE) AS loan_int_rate,
    CAST(NULLIF(loan_status, '') AS UNSIGNED) AS loan_status,
    CAST(NULLIF(loan_percent_income, '') AS DOUBLE) AS loan_percent_income,
    UPPER(TRIM(cb_person_default_on_file)) AS cb_person_default_on_file,
    CAST(NULLIF(cb_person_cred_hist_length, '') AS UNSIGNED) AS cb_person_cred_hist_length
FROM credit_risk_dataset;


-- 2a. Check if duplicate rows are present
SELECT 
    person_age, person_income, person_home_ownership, person_emp_length, 
    loan_intent, loan_grade, loan_amnt, loan_int_rate, loan_status, 
    loan_percent_income, cb_person_default_on_file, cb_person_cred_hist_length,
    COUNT(*) AS dup_count
FROM credit_risk_staging
GROUP BY 
    person_age, person_income, person_home_ownership, person_emp_length, 
    loan_intent, loan_grade, loan_amnt, loan_int_rate, loan_status, 
    loan_percent_income, cb_person_default_on_file, cb_person_cred_hist_length
HAVING COUNT(*) > 1;


-- 2b. Delete exact duplicate records through a CTE using window function ROW_NUMBER()
CREATE TABLE credit_risk_clean AS
WITH RankedData AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY person_age, person_income, person_home_ownership, 
                            person_emp_length, loan_intent, loan_grade, loan_amnt, 
                            loan_int_rate, loan_status, loan_percent_income, 
                            cb_person_default_on_file, cb_person_cred_hist_length
               ORDER BY loan_amnt
           ) AS row_num
    FROM credit_risk_staging
)
SELECT 
    person_age, person_income, person_home_ownership, person_emp_length, 
    loan_intent, loan_grade, loan_amnt, loan_int_rate, loan_status, 
    loan_percent_income, cb_person_default_on_file, cb_person_cred_hist_length
FROM RankedData
WHERE row_num = 1;


-- 3a. Check impossible age/employment data entries
SELECT * 
FROM credit_risk_clean
WHERE person_age > 100 OR person_emp_length > 80;


-- 3b. Remove impossible age/employment data entries
DELETE FROM credit_risk_clean 
WHERE person_age > 100 OR person_emp_length > 80;


-- 4a. Check for NULL/Blank values in all columns
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN person_age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN person_income IS NULL THEN 1 ELSE 0 END) AS null_income,
    SUM(CASE WHEN person_home_ownership IS NULL OR person_home_ownership = '' THEN 1 ELSE 0 END) AS null_home_ownership,
    SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) AS null_emp_length,
    SUM(CASE WHEN loan_intent IS NULL OR loan_intent = '' THEN 1 ELSE 0 END) AS null_loan_intent,
    SUM(CASE WHEN loan_grade IS NULL OR loan_grade = '' THEN 1 ELSE 0 END) AS null_loan_grade,
    SUM(CASE WHEN loan_amnt IS NULL THEN 1 ELSE 0 END) AS null_loan_amnt,
    SUM(CASE WHEN loan_int_rate IS NULL THEN 1 ELSE 0 END) AS null_loan_int_rate,
    SUM(CASE WHEN loan_status IS NULL THEN 1 ELSE 0 END) AS null_loan_status,
    SUM(CASE WHEN loan_percent_income IS NULL THEN 1 ELSE 0 END) AS null_percent_income,
    SUM(CASE WHEN cb_person_default_on_file IS NULL OR cb_person_default_on_file = '' THEN 1 ELSE 0 END) AS null_default_on_file,
    SUM(CASE WHEN cb_person_cred_hist_length IS NULL THEN 1 ELSE 0 END) AS null_cred_hist_length
FROM credit_risk_clean;

-- 4b. So, we get 887 null values for null_emp_length and 3094 for null_loan_int_rate
-- So, now we Impute missing employment length to 0 assuming newly joined 
UPDATE credit_risk_clean
SET person_emp_length = 0
WHERE person_emp_length IS NULL;

-- Impute missing interest rates based on average rate per loan grade
UPDATE credit_risk_clean c
JOIN (
    SELECT loan_grade, ROUND(AVG(loan_int_rate), 2) AS avg_rate
    FROM credit_risk_clean
    WHERE loan_int_rate IS NOT NULL
    GROUP BY loan_grade
) avg_table ON c.loan_grade = avg_table.loan_grade
SET c.loan_int_rate = avg_table.avg_rate
WHERE c.loan_int_rate IS NULL;

-- 4c. Check again if any null values are present
SELECT 
    COUNT(*) AS total_clean_rows,
    SUM(CASE WHEN loan_int_rate IS NULL THEN 1 ELSE 0 END) AS null_interest_rates,
    SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) AS null_emp_length
FROM credit_risk_clean;
-- Since 0 NULL values now, we can go for data analysis


