# Bank Loan Repayment Analysis

## Problem Statement
To analyze and understand the factors influencing loan repayment success, focusing on borrower demographics, loan characteristics, and payment behaviours to identify patterns in "good" vs. "bad" loans.

## Need and Objective
The primary need for this analysis is to enable banks and lending institutions to gain insights into loan repayment dynamics. Banks can better assess borrower risk and improve loan decision-making processes by identifying key factors that contribute to timely payments, such as income level, loan purpose, and instalment size. The objective is to uncover trends that impact loan repayment success, allowing for more informed strategies in lending, risk management, and customer profiling.


## Data Structure
Data Structure and Columns
Here’s a breakdown of each column in the dataset:

* **id** - Unique identifier for each loan record.
* **address_state** - The state where the borrower resides.
* **application_type** - Type of loan application, indicating if it’s an individual or joint application.
* **emp_length** - The number of years the borrower has been employed, indicating employment stability.
* **emp_title** - Job title of the borrower, giving context to their profession.
* **grade** - Internal grading system representing credit risk (e.g., A, B, C).
* **home_ownership** - Home ownership status, such as renting, owning, or mortgaged, may influence repayment capability.
* **issue_date** - Date when the loan was issued.
* **last_credit_pull_date** - The date of the last credit report pulled for the borrower shows recent credit activity.
* **last_payment_date** - Date of the borrower’s last payment, indicating recent payment behaviour.
* **loan_status** - Current status of the loan (e.g., Fully Paid, Current, Charged Off).
* **next_payment_date** - Date of the upcoming scheduled payment.
* **member_id** - Unique ID for each borrower, allowing for tracking individual payment behaviour.
* **purpose** - Purpose for which the loan was taken, such as debt consolidation or home improvement.
* **sub_grade** - Further breakdown of the loan grade, giving finer risk detail (e.g., B1, B2).
* **term** - Loan term length (e.g., 36 or 60 months).
* **verification_status** - Indicates if borrower details, such as income, were verified.
* **annual_income** - The borrower’s annual income, a measure of financial capacity.
* **dti** - Debt-to-Income ratio, which shows how much of the income goes toward debt repayment.
* **instalment** - Monthly instalment amount, showing the loan’s payment burden.
* **int_rate** - Interest rate of the loan, indicating the cost of borrowing.
* **loan_amount** - Original loan amount, reflecting the borrower’s requested amount.
* **total_acc** - Total credit accounts of the borrower, providing credit history depth.
* **total_payment** - Total amount paid by the borrower, indicating repayment progress.
## Analysis to be performed
* General Loan Insights
* Good vs. Bad Loans
* Regional Analysis
* Monthly and Long-Term Analysis
* Purpose-Based Analysis
* Home Ownership Analysis
* Loan Status Breakdown
* Annual Income vs. Loan Amount
* Employment Analysis
* Interest Rate and Installment Analysis
* Verification Status Insights


## Analysis
```sql
USE BANKDB;
```
## 1. General Loan Insights

### 1.1 Total Number of Applications
```sql
SELECT COUNT(id) as total_loan_applications 
FROM bank_data;
```
### 1.2 Total funded amount
```sql
SELECT sum(loan_amount)/1000000 as total_funded_amount_in_millions 
FROM bank_data;
```

### 1.3 Total payment received
```sql
SELECT sum(total_payment)/1000000 as total_payment_recieved_in_millions
FROM bank_data; 
```

### 1.4 What is the average interest rate and debt-to-income (DTI) ratio of all loan applications?
```sql
SELECT ROUND(AVG(int_rate),3)*100 as Avg_interest_rate, ROUND(AVG(dti),3)*100 as Avg_debt_to_income
FROM
bank_data;
```
* **Total Number of Applications:** 38,576 loan applications.
* **Total Funded Amount:** The total loan amount funded is approximately 35.8 billion.
* **Total Payments Received:** About 473 million in total payments have been received.
* **Average Interest Rate:** 12%, indicating a moderate rate for the loans.
* **Average Debt-to-Income Ratio:** 13.3%, showing the borrowers' ability to manage debt relative to their income.

## 2. Good vs. Bad Loans:
### 2.1 What percentage of loan applications are considered good (paid on time or fully paid off)?
```sql
SELECT DISTINCT loan_status FROM bank_data;

SELECT COUNT(*) as Total_app,
COUNT(CASE WHEN loan_status in ('Fully Paid', 'Current') THEN 'Good Loan'
    END) as No_good_loans,
COUNT(CASE WHEN loan_status in ('Fully Paid', 'Current') THEN 'Good Loan'
    END)*100/COUNT(*) AS percentage_of_good_loan
FROM 
bank_data;
```
### 2.2 What percentage of loan applications are considered bad (borrowers who failed to repay)?
```sql
SELECT COUNT(*) as Total_app,
COUNT(CASE WHEN loan_status not in ('Fully Paid', 'Current') THEN 'Bad Loan'
    END) as No_good_loans,
COUNT(CASE WHEN loan_status not in ('Fully Paid', 'Current') THEN 'Bad Loan'
    END)*100/COUNT(*) AS percentage_of_good_loan
FROM 
bank_data;
```

### 2.3 What is the total amount received from good loans compared to bad loans?
```sql
WITH good_bad_loan AS(
SELECT CASE WHEN loan_status in ('Fully Paid', 'Current') THEN 'Good Loan'
	ELSE 'Bad Loan'
    END AS Good_or_Bad_loan,
    total_payment
	FROM bank_data)
SELECT 
Good_or_Bad_loan, ROUND(SUM(total_payment)/1000000,2) AS total_payment_millions
FROM good_bad_loan
GROUP BY Good_or_Bad_loan;
```

### 2.4 What is the trend in the repayment behavior over time for good vs. bad loans?
```sql
SELECT 
    DATE_FORMAT(issue_date, '%Y-%m') AS month,
    SUM(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 ELSE 0 END) AS good_loans,
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END) AS bad_loans
FROM bank_data
GROUP BY month
ORDER BY month;
```
* **Percentage of Good Loans:** 86.18% of loan applications are considered good (either fully paid or current).
* **Percentage of Bad Loans:** 13.82% of applications are bad loans (defaults or charged off).
* **Good Loan Payments:** Good loans contributed approximately 435.79 million in payments, while bad loans contributed 37.28 million.
* **Trend of Good vs. Bad Loans Over Time:** The repayment behavior fluctuates over time, with monthly variations in the number of good and bad loans.

## 3. Regional Analysis
### 3.1 What are the total loan amounts disbursed in each state?
```sql
SELECT address_state, ROUND(SUM(loan_amount)/1000000,2) as amount_disbursed
FROM bank_data
GROUP BY address_state
ORDER BY amount_disbursed DESC;
```

### 3.2 Which state has the highest number of loan applications?
```sql
SELECT address_state , COUNT(*) as no_of_loan_applications
FROM bank_data
GROUP BY address_state
ORDER BY no_of_loan_applications DESC; 
```

### 3.3 How do the rates of good and bad loans compare by state?
```sql
WITH good_bad_loan AS(
SELECT address_state,
SUM(CASE WHEN loan_status in ('Fully Paid', 'Current') THEN 1 ELSE 0 END) AS Good_loan,
SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS Bad_loan
FROM bank_data
GROUP BY address_state)
SELECT 
address_state,
ROUND((Good_loan/(Good_loan+Bad_loan))*100,2) AS Good_loan_percentage,
ROUND((Bad_loan/(Good_loan+Bad_loan))*100,2) AS Bad_loan_percentage
FROM good_bad_loan
ORDER BY Good_loan_percentage DESC;
```
* **Total Loan Amounts by State:** States with higher populations or economic activity generally have higher loan disbursements.
* **State with the Most Applications:** There is a clear concentration of loan applications in certain states, likely linked to economic and demographic factors.
* **Good vs. Bad Loans by State:** States with higher good loan percentages indicate financial stability or better loan management, while states with higher bad loan percentages may need better risk management or financial education.


## 4. Monthly and Long-Term Analysis:
**Transforming issue_date column from text format to date**
```sql
UPDATE bank_data
SET issue_date = STR_TO_DATE(`issue_date`, '%d-%m-%Y')
WHERE issue_date IS NOT NULL;
ALTER TABLE bank_data
CHANGE COLUMN issue_date issue_date DATE NULL;
```
### 4.1 What is the monthly trend in the number of loan applications submitted?
```sql
SELECT MONTH(issue_date) as month, COUNT(id) as no_of_applications
FROM bank_data
GROUP BY MONTH(issue_date)
ORDER BY month;
```

### 4.2 How much money has been lent and received by the bank each month (net interest income)?
```sql
SELECT MONTH(issue_date) as month, 
	ROUND((SUM(total_payment) - SUM(loan_amount))/1000000,2) as net_interest_income_millions
FROM bank_data
GROUP BY MONTH(issue_date)
ORDER BY month;
```
* **Monthly Trend in Loan Applications:** There is an increasing trend in loan applications over time, which might indicate an expanding market or more aggressive marketing strategies.
* **Net Interest Income by Month:** The bank’s net interest income (loan payments minus loan amounts) fluctuates over time, indicating seasonality or changing market conditions.

## 5. Purpose-Based Analysis
### 5.1 What are the most common purposes for which loans are taken?
```sql
SELECT DISTINCT purpose, ROUND((COUNT(id)/(SELECT COUNT(*) FROM bank_data))*100,2) as percentage_of_applications
FROM bank_data
GROUP BY purpose
ORDER BY percentage_of_applications DESC;
```

### 5.2 How does the loan repayment success rate vary by purpose?
```sql
SELECT 
    purpose,
    COUNT(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 END) AS good_loans,
    COUNT(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 END) AS bad_loans,
    COUNT(*) AS total_loans,
    ROUND(
        (COUNT(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 END) / COUNT(*)) * 100, 
        2
    ) AS success_rate_percentage
FROM bank_data
GROUP BY purpose
ORDER BY success_rate_percentage DESC;
```

### 5.3 Which loan purposes contribute the most to bad loans?
```sql
SELECT DISTINCT purpose,
ROUND( (SUM(
		CASE 
			WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) 
            OVER (PARTITION BY purpose) / (SELECT COUNT(*) FROM bank_data WHERE loan_status = 'Charged Off')) *100,2)
as percentage_of_bad_loans
FROM bank_data
ORDER BY percentage_of_bad_loans DESC;
```
* **Most Common Loan Purposes:** A significant percentage of loan applications are for common purposes like debt consolidation, home improvements, or education.
* **Repayment Success by Purpose:** Loan purposes like home improvements or education tend to have higher repayment success rates compared to debt consolidation or personal loans.
* **Bad Loans by Purpose:** Certain loan purposes (e.g., debt consolidation) contribute disproportionately to bad loans, suggesting riskier profiles.

## 6. Home Ownership Analysis
### 6.1 How does home ownership status impact the likelihood of timely payments?
```sql
SELECT home_ownership,
SUM(CASE WHEN loan_status IN ('Fully paid','Current') THEN 1 ELSE 0 END) as No_of_good_loans,
SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) as No_of_bad_loans,
COUNT(*) as Total_loans,
ROUND( SUM(CASE WHEN loan_status IN ('Fully paid','Current') THEN 1 ELSE 0 END)*100 / COUNT(*) ,2) as Timely_payment_percentage
FROM bank_data
GROUP BY home_ownership
ORDER BY Timely_payment_percentage DESC;
```

### 6.2 What percentage of loan applicants are homeowners, renters, or have a mortgage?
```sql
SELECT b.home_ownership, b.total_loans, b.total_loans*100 / a.overall_loans as percentage_of_loans
FROM
(SELECT COUNT(*)  as overall_loans
FROM bank_data) AS a
CROSS JOIN
(SELECT home_ownership, COUNT(*) as total_loans
FROM bank_data
GROUP BY home_ownership) AS b;
```
### 6.3 How do the average loan amounts and repayment success differ by home ownership status?
```sql
SELECT home_ownership, 
ROUND(AVG(loan_amount)/1000,2) as avg_loan_amount_in_k$,
ROUND(COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN 1 END) * 100.0 / COUNT(*),2) AS repayment_success_rate
FROM bank_data
GROUP BY home_ownership
ORDER BY repayment_success_rate DESC;
```
* **Impact of Home Ownership on Repayment:** Home ownership status does not significantly impact loan repayment behavior.
* **Home Ownership Distribution:** A large portion of applicants are homeowners, followed by renters and those with mortgages.
* **Repayment Success by Home Ownership:** Homeowners have slightly better repayment success rates, but the difference is not substantial.

## 7. Loan Status Breakdown:
### 7.1 How many loans have been paid off, are pending, or have been charged off?

```sql
SELECT DISTINCT loan_status , COUNT(*) OVER (PARTITION BY loan_status) as no_of_applications
FROM bank_data
ORDER BY no_of_applications DESC;
```
### 7.2 What are the repayment trends over the past year(s)?
```sql
SELECT 
    YEAR(last_payment_date) AS year,
    COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) * 100.0 / COUNT(*) AS repayment_success_rate,
    SUM(total_payment) AS total_repayment_amount
FROM bank_data
WHERE  last_payment_date IS NOT NULL 
GROUP BY YEAR(last_payment_date)
ORDER BY year;
```
* **Loan Status Distribution:** A large percentage of loans are either paid off or currently active, with a smaller proportion defaulted or charged off.
* **Repayment Trends Over Time:** Over the past years, loan repayment success has been steady, but there is room for improvement, especially for older loans.

## 8. Annual Income vs. Loan Amount:
### 8.1 What is the correlation between annual income and the average loan amount taken?
```sql
SELECT 
    FLOOR(annual_income / 100000) * 100000 AS income_range,
    AVG(loan_amount) AS average_loan_amount
FROM bank_data
GROUP BY income_range
ORDER BY income_range;
```
```sql
SELECT @firstValue:=avg(annual_income) as mean1,
	@secondValue:=avg(loan_amount) as mean2,
    @division:=(stddev_samp(annual_income) * stddev_samp(loan_amount))  as std
FROM bank_data;
select ROUND ( sum( ( annual_income - @firstValue ) * (loan_amount - @secondValue) ) / ((count(annual_income) -1) * @division), 2 ) as correlation
FROM bank_data;
```

### 8.2 How many borrowers have taken loans higher than a set multiple of their annual income?
```sql
SELECT
CASE WHEN multiples >= 0.8 THEN "0.8x more than annual_income"
	WHEN multiples >= 0.5 AND multiples < 0.8 THEN "0.5x more than annual_income"
    ELSE "Less than 0.5x annual_income"
    END as multiple_more_than_income,
COUNT(*)
FROM (
SELECT loan_amount/annual_income as multiples from bank_data) as loan_multiples
GROUP BY multiple_more_than_income;
```

### 8.3 How does income level impact loan repayment success (good vs. bad loans)?
```sql
SELECT MIN(annual_income) as min , MAX(annual_income) as max from bank_data;
SELECT annual_income from bank_data ORDER BY annual_income DESC;
SELECT 
    CASE 
        WHEN annual_income < 30000 THEN '< 30k'
        WHEN annual_income BETWEEN 30000 AND 60000 THEN '30k-60k'
        WHEN annual_income BETWEEN 60001 AND 100000 THEN '60k-100k'
        WHEN annual_income BETWEEN 100001 AND 150000 THEN '100k-150k'
        WHEN annual_income BETWEEN 150001 AND 200000 THEN '150k-200k'
        WHEN annual_income > 200000 THEN '> 200k'
    END AS income_level,
    ROUND(COUNT(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 END) * 100.0 / COUNT(*) , 2) AS good_loan_percentage,
    ROUND(COUNT(CASE WHEN loan_status IN ('Charged Off', 'Defaulted') THEN 1 END) * 100.0 / COUNT(*), 2) AS bad_loan_percentage
FROM bank_data
GROUP BY income_level
ORDER BY income_level;
```
* **Income vs. Loan Amount:** There is little correlation between annual income and the loan amount taken, suggesting that borrowers’ income levels do not significantly impact the size of loans they apply for.
* **Borrowers Taking Loans Higher than Annual Income:** Most borrowers take loans that are less than 50% of their annual income, which can be a positive indicator for the bank’s risk management.
* **Income Level and Repayment Success:** Higher-income levels correlate with better repayment success. Borrowers earning over $200k tend to have the highest repayment success (89.79%), while those earning under $30k show the lowest (82.56%).

## 9. Employment Analysis
### 9.1 What is the distribution of loan amounts by employment length?
```sql
SELECT emp_length, AVG(loan_amount) as avg_loan_amount
FROM bank_data
GROUP BY emp_length
ORDER BY emp_length;
```

### 9.2 How does the repayment success rate vary by different employment lengths?
```sql
SELECT
emp_length, 
ROUND(COUNT(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 END) * 100.0 / COUNT(*) , 2) AS good_loan_percentage,
ROUND(COUNT(CASE WHEN loan_status IN ('Charged Off', 'Defaulted') THEN 1 END) * 100.0 / COUNT(*), 2) AS bad_loan_percentage
from bank_data
GROUP BY emp_length
ORDER BY emp_length;
```
* **Loan Amounts by Employment Length:** There seems to be a positive correlation between employment length and the average loan amount taken.
* **Repayment Success by Employment Length:** Employment length does not seem to significantly affect loan repayment success, with similar trends across all employment levels.

## 10. Interest Rate and Installment Analysis
### 10.1 What is the average interest rate and how does it differ by grade?
```sql
SELECT grade, ROUND( AVG(int_rate)*100, 2) as avg_interest_rate  FROM bank_data
GROUP BY grade
ORDER BY grade;
```

### 10.2  What is the average installment amount, and how does it relate to loan repayment status?
```sql
SELECT DISTINCT installment FROM bank_data ORDER BY installment DESC;

SELECT 
    CASE 
        WHEN installment < 200 THEN '< 200'
        WHEN installment BETWEEN 200 AND 400 THEN '200-400'
        WHEN installment BETWEEN 400 AND 600 THEN '400-600'
        WHEN installment BETWEEN 600 AND 800 THEN '600-800'
        WHEN installment BETWEEN 800 AND 1000 THEN '800-1000'
        WHEN installment > 1000 THEN '>1000'
    END AS installment_level,
    ROUND(COUNT(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 END) * 100.0 / COUNT(*) , 2) AS good_loan_percentage,
    ROUND(COUNT(CASE WHEN loan_status IN ('Charged Off', 'Defaulted') THEN 1 END) * 100.0 / COUNT(*), 2) AS bad_loan_percentage
FROM bank_data
GROUP BY installment_level
ORDER BY installment_level;
```

### 10.3 What is the distribution of interest rates for good vs. bad loans?
```sql
SELECT MIN(int_rate), MAX(int_rate) from bank_data;
SELECT 
CASE WHEN int_rate < 0.10 THEN "<10%" 
	WHEN int_rate BETWEEN 0.10 AND 0.15 THEN "10% - 15%"
    WHEN int_rate BETWEEN 0.15 AND 0.20 THEN "15% - 20%"
    ELSE ">20%" 
    END AS int_rate_levels,
    ROUND(COUNT(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 END) * 100.0 / COUNT(*) , 2) AS good_loan_percentage,
    ROUND(COUNT(CASE WHEN loan_status IN ('Charged Off', 'Defaulted') THEN 1 END) * 100.0 / COUNT(*), 2) AS bad_loan_percentage
FROM 
bank_data
GROUP BY int_rate_levels;
```
* **Interest Rate by Grade:** Interest rates increase as the grade of the loan goes from A to G, with the highest interest rate (21%) for Grade G and the lowest (7.3%) for Grade A.
* **Installment Amount and Loan Repayment:** Lower installment amounts are associated with higher loan repayment success. Higher installment amounts, particularly those between $800 and $1000, show more repayment challenges.
* **Interest Rates for Good vs. Bad Loans:** Higher interest rates are correlated with a higher likelihood of default, suggesting that lower interest rates could improve loan repayment success.


## 11. Verification Status Insights
### 11.1 How does the verification status of applications impact loan repayment success?
```sql
SELECT verification_status, 
ROUND(COUNT(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 END) * 100.0 / COUNT(*) , 2) AS good_loan_percentage,
ROUND(COUNT(CASE WHEN loan_status IN ('Charged Off', 'Defaulted') THEN 1 END) * 100.0 / COUNT(*), 2) AS bad_loan_percentage
FROM bank_data
GROUP BY verification_status;
```

### 11.2 What is the average loan amount and interest rate for verified vs. non-verified applications?
```sql
SELECT verification_status, ROUND(AVG(loan_amount),2) as Average_loan_amount, ROUND(AVG(int_rate),2)*100 as Average_int_rate
FROM bank_data
GROUP BY verification_status
ORDER BY Average_loan_amount;
```
* **Impact of Verification Status on Repayment:** Verification status has minimal impact on repayment success, with "Not Verified" loans slightly outperforming "Verified" and "Source Verified" loans.
* **Average Loan Amount and Interest Rate by Verification Status:** Verified loans have a higher average loan amount and interest rate compared to non-verified loans, but the difference in repayment success is not significant.



## Final Analysis and Recommendations

### Analysis Summary:
The bank’s lending portfolio demonstrates a solid overall performance, with 86.1% of loans being repaid on time. However, there are notable risks, particularly in certain loan types (debt consolidation) and regions (states with high default rates like NV and NE). High-income borrowers show better repayment success, while loan purpose, interest rates, and loan amount also play critical roles in determining repayment likelihood.

### Key Findings:
- **Bad Loan Trends**: A rising default trend in Q4 requires focused intervention, especially for debt consolidation loans.
- **Regional Disparities**: States like ME and IA show 100% repayment rates, while others have higher default risks.
- **Loan Purpose Impact**: Debt consolidation loans have a high default rate (49%), while wedding loans have the highest repayment success.
- **Income and Employment**: Higher-income borrowers exhibit stronger repayment rates, and longer employment is linked to larger loan amounts.

### Recommendations:
1. **Risk Mitigation Strategies**: Implement more stringent credit assessments, especially for debt consolidation loans, and tailor risk management strategies to high-risk states.
2. **Targeted Offerings**: Focus on high-income borrowers and regions with low default rates, while offering more flexible terms for lower-income applicants to reduce defaults.
3. **Loan Purpose Adjustments**: Reevaluate the terms and conditions of debt consolidation loans to better manage the associated risks.
4. **Regional Strategy**: Adapt loan offerings and repayment strategies to address region-specific financial climates, focusing on high-default states for enhanced risk modeling and management.
5. **Interest Rate Adjustments**: Consider offering lower interest rates to borrowers with strong repayment histories to further boost success rates.

By refining these strategies, the bank can enhance its loan portfolio performance, reduce defaults, and drive long-term profitability.
