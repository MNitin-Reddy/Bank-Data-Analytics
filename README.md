# Bank Loan Lending Analysis

## Problem Statement
To analyze and understand the factors influencing loan repayment success, focusing on borrower demographics, loan characteristics, and payment behaviours to identify patterns in "good" vs. "bad" loans.

## Need and Objective
The primary need for this analysis is to enable banks and lending institutions to gain insights into loan repayment dynamics. Banks can better assess borrower risk and improve loan decision-making processes by identifying key factors that contribute to timely payments, such as income level, loan purpose, and instalment size. The objective is to uncover trends that impact loan repayment success, allowing for more informed strategies in lending, risk management, and customer profiling.


## Data Structure
Data Structure and Columns
Here’s a breakdown of each column in the dataset:

| **Field**                 | **Description**                                           | **Field**              | **Description**                                                |
|---------------------------|-----------------------------------------------------------|------------------------|----------------------------------------------------------------|
| **id**                    | Unique identifier for each loan record.                  | **address_state**      | The state where the borrower resides.                         |
| **application_type**      | Type of loan application, indicating individual/joint.   | **emp_length**         | Number of years the borrower has been employed.               |
| **emp_title**             | Job title of the borrower.                               | **grade**              | Internal grading system for credit risk (e.g., A, B, C).      |
| **home_ownership**        | Home ownership status (e.g., renting, owning).           | **issue_date**         | Date when the loan was issued.                                |
| **last_credit_pull_date** | Date of last credit report pulled.                       | **last_payment_date**  | Date of the borrower’s last payment.                         |
| **loan_status**           | Current loan status (e.g., Fully Paid).           | **next_payment_date**  | Date of the upcoming scheduled payment.                      |
| **member_id**             | Unique ID for each borrower.                             | **purpose**            | Purpose for the loan (e.g., debt consolidation).              |
| **sub_grade**             | Breakdown of loan grade (e.g., B1, B2).                  | **term**               | Loan term length (e.g., 36 or 60 months).                    |
| **verification_status**   | Indicates if borrower details were verified.             | **annual_income**      | Borrower’s annual income.                                     |
| **dti**                   | Debt-to-Income ratio, showing debt repayment burden.     | **instalment**         | Monthly instalment amount.                                    |
| **int_rate**              | Interest rate of the loan.                               | **loan_amount**        | Original loan amount requested.                               |
| **total_acc**             | Total credit accounts of the borrower.                   | **total_payment**      | Total amount paid by the borrower.                           |

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

## Tableau Dashboard
Bank Lending Analysis Dashboard Live -> [Dashboard](https://public.tableau.com/views/LendingDashboard_17332189109360/Summary?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

![Dashboard1](BLA%20Dashboard%201.png)
![Dashboard2](BLA%20Dashboard%202.png)
![Dashboard3](BLA%20Dashboard%203.png)

## Most Impactful Analysis
**How does income level impact loan repayment success (good vs. bad loans)?**

```sql
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
* High-income borrowers show better repayment success, suggesting income is a significant factor in determining repayment behavior.

**What is the trend in repayment behavior over time for good vs. bad loans?**
```sql
SELECT 
    DATE_FORMAT(issue_date, '%Y-%m') AS month,
    SUM(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 ELSE 0 END) AS good_loans,
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END) AS bad_loans
FROM bank_data
GROUP BY month
ORDER BY month;
```
* There is an increasing trend of bad loans toward the end of the year, highlighting a seasonal pattern in default risk.

**Which loan purposes contribute the most to bad loans?**
```sql
SELECT DISTINCT purpose,
ROUND( (SUM(CASE 
			WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) 
            OVER (PARTITION BY purpose) / (SELECT COUNT(*) FROM bank_data WHERE loan_status = 'Charged Off')) *100,2)
as percentage_of_bad_loans
FROM bank_data
ORDER BY percentage_of_bad_loans DESC;
```
* Debt consolidation accounts for a high percentage of bad loans, indicating this purpose as a high-risk area.

**How does home ownership status impact the likelihood of timely payments?**
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
* Minimal difference in repayment success between homeowners and renters, suggesting that ownership status has limited influence on loan repayment.

**What is the total amount received from good loans compared to bad loans?**
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
* The total amount received from good loans is $435.79 million, while bad loans account for $37.28 million. This indicates that a large portion of repayments comes from borrowers who repay on time, whereas bad loans represent a significant loss potential for the bank.

**What is the correlation between instalment amount and loan repayment success?**
```sql
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
* Lower installment amounts correspond with better repayment success, whereas higher installment ranges ($800–$1000) show an increased rate of defaults.

**What is the correlation between annual income and the average loan amount taken?**
```sql
SELECT 
    FLOOR(annual_income / 100000) * 100000 AS income_range,
    AVG(loan_amount) AS average_loan_amount
FROM bank_data
GROUP BY income_range
ORDER BY income_range;

SELECT @firstValue:=avg(annual_income) as mean1,
	@secondValue:=avg(loan_amount) as mean2,
    @division:=(stddev_samp(annual_income) * stddev_samp(loan_amount))  as std
FROM bank_data;
select ROUND ( sum( ( annual_income - @firstValue ) * (loan_amount - @secondValue) ) / ((count(annual_income) -1) * @division), 2 ) as correlation
FROM bank_data;
```
* There is minimal correlation between annual income and the loan amount taken, indicating that the income level does not significantly influence the loan amount borrowed by applicants. Borrowers across various income levels tend to take similar loan amounts.

**View full Analysis ->** [Complete Analysis](Complete%20Analysis.md)

## Final Analysis

This analysis provides a comprehensive view of the bank's lending activities, focusing on repayment trends, demographic influences, and loan characteristics that impact repayment success. Here’s a summary of the key findings:

### General Loan Insights:
A total of 38,576 loan applications were submitted, with a funded amount of $435.76M and total payments received by the bank amounting to $473M.
The average interest rate is 12%, and the average debt-to-income (DTI) ratio is 13.3%.

### Good vs. Bad Loans:
- Approximately 86.1% of loans were categorized as “good” (repaid on time), while 13.82% were “bad” (defaulted).
- Good loans have generated $435.79M, compared to $37.28M from bad loans.
- An increasing trend of bad loans toward the end of the year indicates a need for focused risk management strategies in Q4.

### Regional Analysis:
- California, New York, Texas, and Florida lead in total loan disbursements and application volume.
- Certain states (like ME and IA) have a 100% repayment rate, while others, such as NV and NE, show higher default percentages, suggesting region-specific risk factors.

### Purpose-Based Analysis:
- Debt consolidation is the most common loan purpose, accounting for 47.22% of loans.
- The highest repayment success rate is seen in wedding loans (90.73%), while small business loans have the lowest (74.38%).
- Bad loans are mostly associated with debt consolidation (49%), indicating high-risk factors in these cases.

### Home Ownership Analysis:
- Homeownership has minimal impact on repayment likelihood; homeowners and renters have similar repayment success rates.
- Renters represent 47.8% of applicants, followed by mortgage holders at 44.6%.

### Loan Status and Repayment Trends:
- 32,145 loans have been fully paid, 5,333 are charged off, and 1,098 are active.
- Over the past year, the repayment rate stands at 83.33%, highlighting solid repayment trends in 2023.

### Annual Income vs. Loan Amount:
- There is little correlation between annual income and loan amount, indicating that income alone does not dictate loan size.
- Higher-income borrowers show better repayment success; those earning over $200K have an 89.79% repayment success rate, compared to 82.56% for incomes under $30K.

### Employment and Interest Rate Analysis:
- Employment length correlates positively with loan amount; longer employment duration often reflects larger loans.
- Lower monthly installments correspond with higher repayment success rates, while higher instalments (especially $800–$1000) see more defaults.
- Higher loan interest rates contribute to an increased likelihood of loan default.

### Verification Status:
- Loan verification status shows minimal impact on repayment success, with non-verified loans having a slightly better success rate.

## Recommendations:
1. **Risk Mitigation Strategies**: Implement more stringent credit assessments, especially for debt consolidation loans, and tailor risk management strategies to high-risk states.
2. **Targeted Offerings**: To reduce defaults, focus on high-income borrowers and regions with low default rates while offering more flexible terms for lower-income applicants.
3. **Loan Purpose Adjustments**: Reevaluate the terms and conditions of debt consolidation loans to better manage the associated risks.
4. **Regional Strategy**: Adapt loan offerings and repayment strategies to address region-specific financial climates, focusing on high-default states for enhanced risk modelling and management.
5. **Interest Rate Adjustments**: To further boost success rates, consider offering lower interest rates to borrowers with strong repayment histories.

By refining these strategies, the bank can enhance its loan portfolio performance, reduce defaults, and drive long-term profitability.

