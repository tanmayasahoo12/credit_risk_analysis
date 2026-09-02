-- 1. Overall Portfolio Health Summary
SELECT 
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_portfolio_exposure,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct
FROM credit_risk_clean;


-- 2. Risk Breakdown by Loan Purpose
SELECT 
    loan_intent,
    COUNT(*) AS total_borrowers,
    SUM(loan_amnt) AS total_capital_allocated,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate
FROM credit_risk_clean
GROUP BY loan_intent
ORDER BY default_rate_pct DESC;

-- 3. Risk Breakdown by Loan Grades
SELECT 
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS default_count,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate
FROM credit_risk_clean
GROUP BY loan_grade
ORDER BY loan_grade ASC;


-- 4. Impact of Prior Historical Default
SELECT 
    cb_person_default_on_file AS prior_default_history,
    COUNT(*) AS total_borrowers,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS current_defaults,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate
FROM credit_risk_clean
GROUP BY cb_person_default_on_file;


-- 5. Debt-to-Income (DTI) Leverage Bucketing
SELECT 
    CASE 
        WHEN loan_percent_income < 0.10 THEN '1. DTI <10%'
        WHEN loan_percent_income >=0.10 AND loan_percent_income < 0.20 THEN '2. DTI 10-20%'
        WHEN loan_percent_income >=0.20 AND loan_percent_income < 0.30 THEN '3. DTI 20-30%'
        WHEN loan_percent_income >=0.30 AND loan_percent_income < 0.40 THEN '4. DTI 30-40%'
        ELSE '5. DTI >40%'
    END AS dti_tier,
    COUNT(*) AS total_borrowers,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct
FROM credit_risk_clean
GROUP BY dti_tier
ORDER BY dti_tier ASC;

-- 6. Loan Interest Rate Bucketing Analysis
SELECT 
    CASE 
        WHEN loan_int_rate <= 10.0 THEN '1. Low Rate (< 10%)'
        WHEN loan_int_rate BETWEEN 10.01 AND 15.0 THEN '2. Moderate Rate (10% - 15%)'
        WHEN loan_int_rate BETWEEN 15.01 AND 20.0 THEN '3. High Rate (15% - 20%)'
        ELSE '4. Very High Rate (> 20%)'
    END AS interest_rate_tier,
    COUNT(*) AS total_borrowers,
    SUM(loan_amnt) AS total_exposure,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct
FROM credit_risk_clean
GROUP BY interest_rate_tier
ORDER BY interest_rate_tier ASC;


-- 7. Credit History Bucketing Analysis
SELECT 
	CASE 
      WHEN cb_person_cred_hist_length <= 5 THEN "<=5" 
      WHEN cb_person_cred_hist_length <= 10 THEN "5-10"
      WHEN cb_person_cred_hist_length <= 20 THEN "10-20"
      WHEN cb_person_cred_hist_length <= 30 THEN "20-30"
      ELSE ">30"
    END AS credit_history,
     COUNT(*) AS total_loans_approved,
     SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS overall_default_rate_pct,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss
FROM credit_risk_clean
GROUP BY credit_history
;


-- 8. Risk Adjusted Revenue & Portfolio Profitability Analysis by Loan Grade
SELECT 
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_exposure,
    ROUND(AVG(loan_int_rate), 2) AS avg_rate,
    ROUND(SUM(CASE WHEN loan_status = 0 THEN loan_amnt * (loan_int_rate / 100) ELSE 0 END), 2) AS est_interest_earned,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END), 2) AS total_defaulted_principal,
    -- Net Margin Calculation
    ROUND(
        SUM(CASE WHEN loan_status = 0 THEN loan_amnt * (loan_int_rate / 100) ELSE 0 END) - 
        SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END), 2
    ) AS net_portfolio_profit_loss
FROM credit_risk_clean
GROUP BY loan_grade
ORDER BY loan_grade;



-- 9. Risk-Adjusted Margin % of Total Exposure
SELECT 
    loan_grade,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_exposure,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    -- Interest Earned Yield (% of Exposure)
    ROUND(
        (SUM(CASE WHEN loan_status = 0 THEN loan_amnt * (loan_int_rate / 100) ELSE 0 END) * 100.0) / SUM(loan_amnt), 
        2
    ) AS interest_yield_pct,
    --  Principal Loss Rate (% of Exposure)
    ROUND(
        (SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) * 100.0) / SUM(loan_amnt), 2
    ) AS principal_loss_pct,
    -- Net Portfolio Margin % (% Yield - % Loss)
    ROUND(
        (
            SUM(CASE WHEN loan_status = 0 THEN loan_amnt * (loan_int_rate / 100) ELSE 0 END) - 
            SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END)
        ) * 100.0 / SUM(loan_amnt), 2
    ) AS net_margin_pct
FROM credit_risk_clean
GROUP BY loan_grade
ORDER BY loan_grade ASC;



-- 10. Non-Linear Continous Risk Bounding (Finding Tipping Points)
SELECT 
    ROUND(AVG(loan_percent_income),2) AS avg_loan_percent_income,
    FLOOR(loan_percent_income * 10) / 10 AS dti_decile_start,
    round((FLOOR(loan_percent_income * 10) / 10) + 0.10,1) AS dti_decile_end,
    COUNT(*) AS borrower_count,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct
FROM credit_risk_clean
GROUP BY dti_decile_start, dti_decile_end
HAVING borrower_count > 50
ORDER BY dti_decile_start;


-- 11. Grade wise Risk Tipping Analysis
SELECT 
    loan_grade,
    CASE 
        WHEN loan_percent_income < 0.10 THEN '1. DTI < 10%'
        WHEN loan_percent_income BETWEEN 0.10 AND 0.199 THEN '2. DTI 10-20%'
        WHEN loan_percent_income BETWEEN 0.20 AND 0.299 THEN '3. DTI 20-30%'
        WHEN loan_percent_income BETWEEN 0.30 AND 0.399 THEN '4. DTI 30-40%'
        ELSE '5. DTI > 40%'
    END AS dti_5_band,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_exposure,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct
FROM credit_risk_clean
GROUP BY loan_grade, dti_5_band
ORDER BY loan_grade ASC, dti_5_band ASC;


-- 12. Quantitative Risk Mitigation Simulation
SELECT 
    '1. Current Portfolio (Baseline)' AS policy_scenario,
    COUNT(*) AS total_loans_approved,
    SUM(loan_amnt) AS total_exposure_usd,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_default_count,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS portfolio_default_rate_pct,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss
FROM credit_risk_clean
UNION ALL
SELECT 
    '2. Proposed Risk-Optimized Policy (Tier-I)' AS policy_scenario,
    COUNT(*) AS total_loans_approved,
    SUM(loan_amnt) AS total_exposure_usd,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS total_default_count,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS portfolio_default_rate_pct,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss
FROM credit_risk_clean
WHERE loan_grade IN ('A', 'B', 'C') 
  AND loan_percent_income < 0.30;
  
  
-- 13. Divergence Analysis for Grades D–G (Default vs. Non-Default)
-- 13a. Continuous Variables Summary (Averages & Key Ratios)
SELECT 
    loan_status,
    CASE WHEN loan_status = 1 THEN 'Defaulted (Bad)' ELSE 'Non-Defaulted (Good)' END AS borrower_class,
    COUNT(*) AS borrower_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_subgroup,
    -- Financial Leverage & Rates
    ROUND(AVG(loan_percent_income), 4) AS avg_dti,
    ROUND(AVG(loan_int_rate), 2) AS avg_interest_rate,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
    ROUND(AVG(person_income), 2) AS avg_person_income,
    -- Credit Profile & History
    ROUND(AVG(person_emp_length), 2) AS avg_employment_length_years,
    ROUND(AVG(cb_person_cred_hist_length), 2) AS avg_credit_history_years
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F')
GROUP BY loan_status;

-- 13b. Categorical Distribution: Home Ownership Breakdown (% within class)
SELECT 
    loan_status,
    person_home_ownership,
    COUNT(*) AS borrower_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY loan_status), 
        2
    ) AS pct_within_class
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F')
GROUP BY loan_status, person_home_ownership
ORDER BY person_home_ownership, loan_status;

-- 13c. Categorical Distribution: Historical Default on File (Prior Derogatory Record)
SELECT 
    loan_status,
    cb_person_default_on_file,
    COUNT(*) AS borrower_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY loan_status), 
        2
    ) AS pct_within_class
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F')
GROUP BY loan_status, cb_person_default_on_file
ORDER BY cb_person_default_on_file, loan_status;

-- 13d. Categorical Distribution: Loan Intent / Purpose Breakdown
SELECT 
    loan_intent,
    SUM(CASE WHEN loan_status = 0 THEN 1 ELSE 0 END) AS non_default_count,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS default_count,
    ROUND(
        (SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 
        2
    ) AS segment_default_rate_pct
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F')
GROUP BY loan_intent
ORDER BY segment_default_rate_pct ASC;


-- 14a. Deep-Dive Profile of Homeowners (OWN) vs. Non-Homeowners in Grades D–G
SELECT 
    person_home_ownership,
    COUNT(*) AS total_borrowers,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_borrowers,
    
    -- Default Rate %
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    
    -- Averages across Home Ownership types
    ROUND(AVG(loan_percent_income), 4) AS avg_dti,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate,
    ROUND(AVG(person_income), 2) AS avg_income,
    ROUND(AVG(person_emp_length), 2) AS avg_emp_length,
    ROUND(AVG(loan_amnt), 2) AS avg_loan_amount
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F')
GROUP BY person_home_ownership
ORDER BY default_rate_pct ASC;


-- 14b. Employment Length Buckets in Grades D–G
SELECT 
    CASE 
        WHEN person_emp_length < 2 THEN '1. Short (<2 Yrs)'
        WHEN person_emp_length BETWEEN 2 AND 4.99 THEN '2. Moderate (2-5 Yrs)'
        WHEN person_emp_length BETWEEN 5 AND 9.99 THEN '3. Stable (5-10 Yrs)'
        WHEN person_emp_length >= 10 THEN '4. High Stability (10+ Yrs)'
        ELSE 'Unknown'
    END AS emp_length_bucket,
    COUNT(*) AS total_borrowers,
    SUM(loan_amnt) AS total_exposure,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaulted_borrowers,
    
    -- Default Rate %
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    
    -- Financial Averages
    ROUND(AVG(loan_percent_income), 4) AS avg_dti,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate,
    ROUND(AVG(person_income), 2) AS avg_income
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F')
GROUP BY emp_length_bucket
ORDER BY emp_length_bucket ASC;

-- 14c. Compound Interaction (Homeowner OWN $\times$ Employment Tenure)
SELECT 
    person_home_ownership,
    CASE 
        WHEN person_emp_length < 3 THEN '1. Low Emp (<3 Yrs)'
        WHEN person_emp_length BETWEEN 3 AND 6.99 THEN '2. Mid Emp (3-7 Yrs)'
        WHEN person_emp_length >= 7 THEN '3. High Emp (7+ Yrs)'
        ELSE 'Unknown'
    END AS emp_tier,
    COUNT(*) AS total_borrowers,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    ROUND(AVG(loan_percent_income), 4) AS avg_dti
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F')
GROUP BY person_home_ownership, emp_tier
ORDER BY person_home_ownership ASC, emp_tier ASC;


-- 15. Analysis Script for High DTI (A, B, C Tiers), Home Ownership & Emp length
SELECT 
    person_home_ownership,
    CASE 
        WHEN person_emp_length < 3 THEN '1. Low Emp (<3 Yrs)'
        WHEN person_emp_length BETWEEN 3 AND 7 THEN '2. Mid Emp (3-7 Yrs)'
        WHEN person_emp_length > 7 THEN '3. High Emp (7+ Yrs)'
        ELSE '4. Unknown'
    END AS emp_length_group,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS default_loans,
    ROUND((SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS default_rate_pct,
    ROUND(AVG(loan_percent_income) * 100, 2) AS avg_dti_pct,
    ROUND(AVG(loan_int_rate), 2) AS avg_int_rate
FROM credit_risk_clean
WHERE loan_grade IN ('A', 'B', 'C')
  AND loan_percent_income >= 0.30
GROUP BY 
    person_home_ownership,
    CASE 
        WHEN person_emp_length < 3 THEN '1. Low Emp (<3 Yrs)'
        WHEN person_emp_length BETWEEN 3 AND 7 THEN '2. Mid Emp (3-7 Yrs)'
        WHEN person_emp_length > 7 THEN '3. High Emp (7+ Yrs)'
        ELSE '4. Unknown'
    END
ORDER BY default_rate_pct ASC;