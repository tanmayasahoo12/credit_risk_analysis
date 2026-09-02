-- 1. Portfolio Details of original dataset
SELECT 
    '1. Baseline Portfolio (Current)' AS policy_scenario,
    COUNT(*) AS total_loans_approved,
    SUM(c.loan_amnt) AS total_exposure_usd,
    SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS overall_default_rate_pct,
    ROUND(SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END) *100 / SUM(c.loan_amnt)), 2) AS overall_capital_loss_pct
FROM credit_risk_clean c

UNION ALL

-- 2. Portfolio Details as per new loan approval policy (Tier-I, Tier-II, Tier-III) in Total
SELECT 
    '2. Refined 3-Tier Risk Policy' AS policy_scenario,
    COUNT(*) AS total_loans_approved,
    SUM(c.loan_amnt) AS total_exposure_usd,
    SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS overall_default_rate_pct,
    ROUND(SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END) *100 / SUM(c.loan_amnt)), 2) AS overall_capital_loss_pct
FROM credit_risk_clean c
WHERE 
    -- Tier 1: Core Grades A, B, C with DTI < 30%
    (c.loan_grade IN ('A', 'B', 'C') AND c.loan_percent_income < 0.30)
    OR 
    -- Tier 2: High-DTI Carve-Out for Grades A, B, C (OWN/MORTGAGE + Emp >= 3 Yrs)
    (c.loan_grade IN ('A', 'B', 'C') AND c.loan_percent_income >= 0.30 
     AND c.person_home_ownership IN ('OWN', 'MORTGAGE') 
     AND c.person_emp_length >= 3.0)
    OR 
    -- Tier 3 Scenario 1: Grade D,E,F, DTI < 30%, Home = OWN, Any Emp Length
    (c.loan_grade IN ('D','E','F') AND c.loan_percent_income < 0.30 AND c.person_home_ownership = 'OWN')
    
UNION ALL

-- 3. Portfolio Details as per new loan approval policy (tier-I only)
SELECT 
    '1. Tier-1' AS policy_scenario,
    COUNT(*) AS total_loans_approved,
    SUM(c.loan_amnt) AS total_exposure_usd,
    SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS overall_default_rate_pct,
    ROUND(SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END) *100 / SUM(c.loan_amnt)), 2) AS overall_capital_loss_pct
FROM credit_risk_clean c
WHERE 
    -- Tier 1: Core Grades A, B, C with DTI < 30%
    (c.loan_grade IN ('A', 'B', 'C') AND c.loan_percent_income < 0.30)
    
UNION ALL

-- 3. Portfolio Details as per new loan approval policy (tier-II only)
SELECT 
    '1. Tier-2' AS policy_scenario,
    COUNT(*) AS total_loans_approved,
    SUM(c.loan_amnt) AS total_exposure_usd,
    SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS overall_default_rate_pct,
    ROUND(SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END) *100 / SUM(c.loan_amnt)), 2) AS overall_capital_loss_pct
FROM credit_risk_clean c
WHERE  
-- Tier 2: High-DTI Carve-Out for Grades A, B, C (OWN/MORTGAGE + Emp >= 3 Yrs)
    (c.loan_grade IN ('A', 'B', 'C') AND c.loan_percent_income >= 0.30 
     AND c.person_home_ownership IN ('OWN', 'MORTGAGE') 
     AND c.person_emp_length >= 3.0)
     
UNION ALL

-- 4. Portfolio Details as per new loan approval policy (tier-III only)
SELECT 
    '1. Tier-3' AS policy_scenario,
    COUNT(*) AS total_loans_approved,
    SUM(c.loan_amnt) AS total_exposure_usd,
    SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) AS total_defaults,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS overall_default_rate_pct,
    ROUND(SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END), 2) AS total_defaulted_principal_loss,
    ROUND((SUM(CASE WHEN c.loan_status = 1 THEN c.loan_amnt ELSE 0 END) *100 / SUM(c.loan_amnt)), 2) AS overall_capital_loss_pct
FROM credit_risk_clean c
WHERE  
 -- Tier 3 Scenario 1: Grade D,E,F, DTI < 30%, Home = OWN, Any Emp Length
(c.loan_grade IN ('D','E','F') AND c.loan_percent_income < 0.30 AND c.person_home_ownership = 'OWN')