# Credit Risk Underwriting & Strategy Optimization Framework

**A Data-Driven Portfolio Risk Mitigation & Capital Preservation Project**

**Author:** Tanmaya Kumar Sahoo  
**Role:** Credit Risk & Data Analyst  
**Date:** September 2026  
**GitHub:** [https://github.com/tanmayasahoo12](https://github.com/tanmayasahoo12)  
**Email:** tanmayasahoo11@gmail.com  

---

## Table of Contents
* [Overview](#overview)
* [Key Business Metrics](#key-business-metrics)
* [Problem Statement](#problem-statement)
* [Business Goal](#business-goal)
* [Dataset Description](#dataset-description)
* [Tools & Technical Stack](#tools--technical-stack)
* [Project Directory Structure](#project-directory-structure)
* [How to Run this Project](#how-to-run-this-project)
* [Data Cleaning & Preparation](#data-cleaning--preparation)
* [Exploratory Data Analysis (MySQL)](#exploratory-data-analysis-mysql)
  * [1. Univariate Analysis](#1-univariate-analysis)
  * [2. Multivariate Analysis & Policy Tier Formulation](#2-multivariate-analysis--policy-tier-formulation)
* [Empirical Findings & Policy Framework](#empirical-findings--policy-framework)
* [Power BI Executive Dashboards](#power-bi-executive-dashboards)
* [Final Recommendations & Business Impact](#final-recommendations--business-impact)
  * [Strategic Recommendations](#strategic-recommendations)
  * [Modeled Business Impact](#modeled-business-impact)
* [Author & Contact Details](#author--contact-details)

---

## Overview

This project evaluates an empirical, data-driven credit risk underwriting framework designed to optimize loan approval decisions, minimize capital default exposure, and preserve profitable origination volume.

Through the analysis of **32,409 historical loan origination records**, critical risk concentrations were identified within high Debt-to-Income (DTI) segments and lower credit grades. To replace unconstrained lending practices, a **Refined 3-Tier Risk Policy Framework** was engineered and simulated.

---

## Key Business Metrics

* **Default Rate Reduction:** Decreased the portfolio default rate by **60.8%**, dropping from **21.87% down to 8.58%** (well below the 20% target ceiling).
* **Capital Loss Avoidance:** Reduced defaulted principal losses from **$76.93M to $15.77M**, preserving **$61.17 Million in lending capital** (a **79.5% reduction in dollar loss**).
* **Pipeline Retained:** Approved **25,311 out of 32,409 applicants**, maintaining **78.10% of origination volume** ($222.06M in active portfolio exposure).

---

## Problem Statement

Under the baseline unconstrained underwriting model, incoming loan applicants were approved without risk-tier segmenting. This produced elevated default rates exceeding corporate risk boundaries:

* **Total Pipeline Volume:** 32,409 loans
* **Total Exposure Deployed:** $310.88 Million
* **Baseline Default Count:** 7,088 defaulted borrowers
* **Baseline Default Rate:** **21.87%**
* **Baseline Dollar Loss:** **$76.93 Million** (Capital Loss Rate: 24.75%)

---

## Business Goal

Formulate a data-backed underwriting rule set that eliminates high-risk toxic origination while continuing to fund creditworthy borrowers across prime and subprime tiers.

---

## Dataset Description

The dataset comprises **32,409 credit applicant records** containing demographic, financial, and loan status indicators:

* **`person_age`**: Borrower age (Years).
* **`person_income`**: Annual gross income ($).
* **`person_home_ownership`**: Housing status (`RENT`, `OWN`, `MORTGAGE`, `OTHER`).
* **`person_emp_length`**: Employment history/tenure (Years).
* **`loan_intent`**: Purpose of loan (`PERSONAL`, `EDUCATION`, `MEDICAL`, `VENTURE`, `HOMEIMPROVEMENT`, `DEBTCONSOLIDATION`).
* **`loan_grade`**: Internal risk grade (`A` through `G`).
* **`loan_amnt`**: Requested credit amount ($).
* **`loan_int_rate`**: Interest rate charged (%).
* **`loan_status`**: Target performance variable (`0` = Fully Paid / Non-Default, `1` = Default).
* **`loan_percent_income`**: Debt-to-Income (DTI) ratio derived as `loan_amnt / person_income`.
* **`cb_person_default_on_file`**: Historical record of default (`Y`/`N`).
* **`cb_person_cred_hist_length`**: Credit bureau history length (Years).

> **Source:** Obtained from Kaggle ([Credit Risk Dataset](https://www.kaggle.com/datasets/laotse/credit-risk-dataset)).

---

## Tools & Technical Stack

* **Database Engine:** MySQL 8.0 (Data cleaning, aggregation, window functions, univariate/multivariate query profiling, multi-tier scenario simulation).
* **Business Intelligence:** Microsoft Power BI Desktop (DAX measures, 2-page executive dashboard).
* **Documentation & Storage:** GitHub, Markdown, CSV, PDF.

---

## Project Directory Structure

```text
Credit-Risk-Underwriting-PowerBI/
│
├── README.md                                 <-- Root landing page documentation 
├── Credit_Risk_Project_Report.pdf            <-- Printable PDF project report 
│
├── data/
│   └── credit_risk_clean.csv                 <-- Cleaned raw dataset 
│
├── sql/
│   ├── 01_data_cleaning.sql                  <-- Schema definition & NULL/outlier handling 
│   ├── 02_risk_analysis.sql                  <-- Univariate & Multivariate profiling queries 
│   └── 03_policy_simulation.sql              <-- Scenario simulation & impact analysis
│
├── power_bi/
│   └── Credit_Risk_Dashboard.pbix            <-- Complete interactive dashboard file 
│
└── dashboard_images/
    ├── page1_risk_discovery.png              <-- Page 1 visual screenshot 
    └── page2_policy_impact.png               <-- Page 2 visual screenshot
```

## How to Run this Project

### Prerequisites
* **MySQL Workbench 8.0** or higher
* **Power BI Desktop** (latest build recommended)

### Execution Steps

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/tanmayasahoo12/Credit-Risk-Underwriting-PowerBI.git](https://github.com/tanmayasahoo12/Credit-Risk-Underwriting-PowerBI.git)

2. **Setup MySQL Database:**
* Open MySQL Workbench and execute `sql/01_data_cleaning.sql` to instantiate the database schema and load raw records.
* Run `sql/02_risk_analysis.sql` to execute univariate and multivariate risk queries.
* Run `sql/03_policy_simulation.sql` to view the simulated policy classification matrix.

3. **Open Power BI Dashboard:**
* Launch Power BI Desktop and open `power_bi/Credit_Risk_Dashboard.pbix`.
* If prompted for data source paths, re-link the dataset to `data/credit_risk_clean.csv`.

## Data Cleaning & Preparation

To ensure data integrity and model reliability, systematic data hygiene procedures were executed using MySQL:

1. **Deduplication via Window Functions:**  
   Duplicate records were identified and removed by partitioning the dataset across key applicant attributes (`person_age`, `person_income`, `loan_amnt`, `loan_intent`, `loan_grade`, and `loan_status`) using a Common Table Expression (CTE) combined with the `ROW_NUMBER()` window function. Rows assigned a sequence index greater than 1 were purged.

2. **Removal of Unviable Outliers:**  
   The dataset was screened for biologically and operationally impossible values. Records containing borrower ages exceeding 100 years (`person_age > 100`) or employment tenures exceeding 80 years (`person_emp_length > 80`) were filtered out as invalid data points.

3. **Missing Value Imputation & Treatment:**  
   Null values across critical fields were audited and resolved through business-logic imputation:
   * **Employment Length (`person_emp_length`):** A total of **887 missing values** were identified. These applicants were categorized as newly employed entry-level workers and imputed with **0 years** of tenure.
   * **Interest Rate (`loan_int_rate`):** A total of **3,094 missing values** were identified. Rather than dropping these records or applying a global average, missing values were imputed using the category-specific average interest rate of the applicant's corresponding credit risk grade (`loan_grade`).

## Exploratory Data Analysis (MySQL)

Exploratory data analysis was conducted using MySQL to identify underlying patterns, evaluate variable correlations, and isolate specific risk drivers influencing borrower default behavior. Throughout this analysis, an internal **maximum default risk appetite ceiling of 20.0%** was established as the benchmark for credit policy eligibility.

### 1. Univariate Analysis
Univariate profiling was performed across all primary applicant attributes—including loan intent, Debt-to-Income (DTI) ratio, credit risk grade, employment length, homeownership status, interest rate, credit history length, and prior default history (`Y`/`N`).

Each feature was evaluated individually against `loan_status` to determine its standalone correlation with default rates. For continuous numerical variables (such as DTI and interest rates), segmented binning and bucket analysis were executed to detect threshold non-linearities and pinpoint exact structural inflection points ("risk cliffs") where default probability escalated sharply.

### 2. Multivariate Analysis & Policy Tier Formulation
To isolate compound risk drivers, multivariate cross-tabulations were conducted, beginning with an evaluation of credit risk grades against continuous DTI tiers.

* **DTI Threshold Discovery & Tier 1 (Core Prime) Identification:**  
  Across all credit categories, a prominent structural spike in default frequency occurred once DTI exceeded **30.0% (0.30)**. When evaluated at DTI levels below 0.30, credit grades **A, B, and C** consistently maintained default rates well below the 20.0% risk appetite limit. Consequently, applicants meeting the criteria of **Grades A, B, or C with a DTI < 0.30** were designated as **Tier 1 (Core Prime)**.

* **Tier 2 (High-DTI Prime) Isolation:**  
  Applicants in Grades A, B, and C with DTI ratios exceeding 0.30 initially breached the acceptable 20.0% default threshold. To determine whether specific credit buffers could offset this higher debt burden, secondary variables were layered onto this high-DTI segment. The analysis revealed that when high-DTI prime applicants held property assets (**Homeownership in `OWN` or `MORTGAGE`**) combined with demonstrated job stability (**Employment Length >= 3 years**), the segment default rate dropped back below the 20.0% target ceiling. This combination was established as **Tier 2 (High-DTI Prime)**.

* **Tier 3 (Subprime Homeowner) Isolation:**  
  Lower credit grades (**D, E, and F**) exhibited elevated baseline default rates (>30.0% overall). However, deeper multi-variable segmentation demonstrated that subprime applicants presenting a low debt burden (**DTI < 0.30**) who owned their homes outright (**Homeownership = `OWN`**) achieved default rates below the 20.0% threshold. This targeted carve-out was defined as **Tier 3 (Subprime Homeowner)**.

* **Tier 4 (Toxic Decline):**  
  All remaining loan profiles failing to satisfy the eligibility rules of Tiers 1, 2, or 3 exhibited default rates ranging between 30% and 69%, well in excess of the corporate risk boundary. These applicants were assigned to Tier 4 for automated decline.

## Empirical Findings & Policy Framework

The multi-tier segmentation analysis yielded the following performance distribution across baseline and proposed policy tiers:

| Policy Tier | Eligibility Underwriting Rules | No. of Loans Approved | Capital Deployed | No. of Loans Defaulted | Default Rate | Defaulted Capital | Capital Loss % |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Old Policy:** | | | | | | | |
| **Current Portfolio** | No such rules | 32,409 | $310.88 M | 7,088 | 21.87% | $76.93 M | 24.75% |
| **New Policy:** | | | | | | | |
| **Tier 1: Core Prime** | Grades A–C AND DTI < 30% | 24,150 | $203.95 M | 2,029 | 8.40% | $13.82 M | 6.78% |
| **Tier 2: High-DTI Prime** | Grades A–C AND DTI $\ge$ 30% AND Home in (`OWN`,`MORTGAGE`) AND Emp Tenure $\ge$ 3 Yrs | 881 | $15.54 M | 108 | 12.26% | $1.68 M | 10.79% |
| **Tier 3: Subprime Homeowner** | Grades D–F AND DTI < 30% AND Home = `OWN` | 280 | $2.57 M | 34 | 12.14% | $0.27 M | 10.45% |
| **Total Under New Policy** | **As per Above** | **25,311** | **$222.06 M** | **2,171** | **8.58%** | **$15.77 M** | **7.10%** |
| **Tier 4: Toxic Assets (Decline)** | All remaining loan profiles | 7,098 | $88.82 M | 4,917 | 69.27% | $61.17 M | 68.87% |

## Power BI Executive Dashboards

### Page 1: Baseline Risk & Driver Discovery
![Page 1: Baseline Risk & Driver Discovery](dashboard_images\page1_risk_analysis.png)

### Page 2: Proposed 3-Tier Policy & Portfolio Impact
![Page 2: Proposed 3-Tier Policy & Portfolio Impact](dashboard_images\page2_new_policy_impact.png)

## Final Recommendations & Business Impact

Based on the empirical findings and multi-tier policy simulation, the following strategic measures and operational recommendations are proposed:

### Strategic Recommendations

1. **Deployment of Automated 3-Tier Underwriting Logic**  
   The front-end credit origination engine should immediately integrate the 3-Tier rule matrix. Automated hard stops should be enforced for non-homeowner applicants presenting a DTI ratio greater than 30.0%, effectively eliminating high-risk origination before capital deployment.

2. **Controlled Volume Expansion via Asset-Backed Buffers**  
   Rather than executing blanket credit declines on subprime grades or high-DTI applicants, underwriting guidelines should leverage homeownership (`OWN`/`MORTGAGE`) and employment tenure (>= 3 years) as compensatory factors. This allows the institution to safely capture higher-yielding loan volume in Tiers 2 and 3 under a strict sub-20.0% default limit.

3. **Dynamic Pricing Adjustments for Tier 2 and Tier 3 Segmentations**  
   While Tiers 2 and 3 maintain acceptable default frequencies (12.26% and 12.14% respectively), their loss profiles are higher than Tier 1 prime originations (8.40%). Interest rates and risk premiums for Tiers 2 and 3 should be dynamically calibrated to ensure adequate loss-provisioning coverage and risk-adjusted return on capital (RAROC).

---

### Modeled Business Impact

| Financial Metric | Baseline Model | Proposed Policy | Delta |
| :--- | :---: | :---: | :---: |
| **Total Origination Pipeline Volume** | 32,409 Loans | 25,311 Loans | -21.90% |
| **Deployed Capital Exposure** | $310.88 Million | $222.06 Million | -28.60% |
| **Portfolio Default Rate** | 21.87% | 8.58% | -60.80% |
| **Total Defaulted Capital Loss** | $76.93 Million | $15.77 Million | -79.50% |
| **Net Capital Preserved (Bad Debt)** | — | **$61.17 Million** | **Saved** |

The table above clearly depicts capital loss prevention, structural default rate reduction, and pipeline preservation as per the new policy:

* **Capital Loss Prevention:** Implementation of the framework prevents **$61.17 Million in bad debt write-offs**, representing a **79.5% dollar-loss reduction** compared to the baseline portfolio.
* **Structural Default Rate Reduction:** The portfolio default rate drops by **60.8% relative**, moving from **21.87% down to 8.58%**, bringing institutional credit risk well inside the maximum 20.0% appetite boundary.
* **Pipeline Preservation:** The policy approves **25,311 out of 32,409 applicants**, retaining **78.10% of origination volume** ($222.06 Million in active capital exposure) and safeguarding ongoing interest revenue streams.

## Author & Contact Details

* **Author:** Tanmaya Kumar Sahoo
* **Role:** Credit Risk & Data Analyst
* **GitHub:** [https://github.com/tanmayasahoo12](https://github.com/tanmayasahoo12)
* **Email:** [tanmayasahoo11@gmail.com](mailto:tanmayasahoo11@gmail.com)
