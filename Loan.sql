USE demo;

SELECT * FROM bank_data;

-- 1. General Loan Insights

-- 1.1 Total Number of Applications
SELECT COUNT(id) as total_loan_applications 
FROM bank_data;
-- we have 38,576 loan appliations

-- 1.2 Total funded amount
SELECT sum(loan_amount)/1000000 as total_funded_amount_in_millions 
FROM bank_data;

-- 1.3 Total payment received
SELECT sum(total_payment)/1000000 as total_payment_recieved_in_millions
FROM bank_data; 
-- 473 million

-- 1.4 What is the average interest rate and debt-to-income (DTI) ratio of all loan applications?
SELECT ROUND(AVG(int_rate),3)*100 as Avg_interest_rate, ROUND(AVG(dti),3)*100 as Avg_debt_to_income
FROM
bank_data;
-- Average Interest rate = 12%
-- Average DTI = 13.3%

-- 2. Good vs. Bad Loans:
-- 2.1 What percentage of loan applications are considered good (paid on time or fully paid off)?
SELECT DISTINCT loan_status FROM bank_data;

SELECT COUNT(*) as Total_app,
COUNT(CASE WHEN loan_status in ('Fully Paid', 'Current') THEN 'Good Loan'
    END) as No_good_loans,
COUNT(CASE WHEN loan_status in ('Fully Paid', 'Current') THEN 'Good Loan'
    END)*100/COUNT(*) AS percentage_of_good_loan
FROM 
bank_data;
-- 86.1753% good loans out of 38576 i.e. 335243

-- 2.2 What percentage of loan applications are considered bad (borrowers who failed to repay)?
SELECT COUNT(*) as Total_app,
COUNT(CASE WHEN loan_status not in ('Fully Paid', 'Current') THEN 'Bad Loan'
    END) as No_good_loans,
COUNT(CASE WHEN loan_status not in ('Fully Paid', 'Current') THEN 'Bad Loan'
    END)*100/COUNT(*) AS percentage_of_good_loan
FROM 
bank_data;
-- 5333 i.e. 13.824% Bad Loans

-- 2.3 What is the total amount received from good loans compared to bad loans?
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
-- Good -> 435.79M
-- Bad -> 37.28M

-- 2.4 What is the trend in the repayment behavior over time for good vs. bad loans?
SELECT 
    DATE_FORMAT(issue_date, '%Y-%m') AS month,
    SUM(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 ELSE 0 END) AS good_loans,
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END) AS bad_loans
FROM bank_data
GROUP BY month
ORDER BY month;

-- 3. Regional Analysis
-- 3.1 What are the total loan amounts disbursed in each state?
SELECT address_state, ROUND(SUM(loan_amount)/1000000,2) as amount_disbursed
FROM bank_data
GROUP BY address_state
ORDER BY amount_disbursed DESC;

-- 3.2 Which state has the highest number of loan applications?
SELECT address_state , COUNT(*) as no_of_loan_applications
FROM bank_data
GROUP BY address_state
ORDER BY no_of_loan_applications DESC; 

-- 3.3 How do the rates of good and bad loans compare by state?
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
FROM good_bad_loan;

-- 4. Monthly and Long-Term Analysis:
-- Transforming issue_date column from text format to date
UPDATE bank_data
SET issue_date = STR_TO_DATE(`issue_date`, '%d-%m-%Y')
WHERE issue_date IS NOT NULL;
ALTER TABLE bank_data
CHANGE COLUMN issue_date issue_date DATE NULL;

-- 4.1 What is the monthly trend in the number of loan applications submitted?
SELECT MONTH(issue_date) as month, COUNT(id) as no_of_applications
FROM bank_data
GROUP BY MONTH(issue_date)
ORDER BY month;
-- increasing in application trend over the months

-- 4.2 How much money has been lent and received by the bank each month (net interest income)?
SELECT MONTH(issue_date) as month, 
	ROUND((SUM(total_payment) - SUM(loan_amount))/1000000,2) as net_interest_income_millions
FROM bank_data
GROUP BY MONTH(issue_date)
ORDER BY month;

-- 5. Purpose-Based Analysis
-- 5.1 What are the most common purposes for which loans are taken?
SELECT DISTINCT purpose, ROUND((COUNT(id)/(SELECT COUNT(*) FROM bank_data))*100,2) as percentage_of_applications
FROM bank_data
GROUP BY purpose
ORDER BY percentage_of_applications DESC;

-- 5.2 How does the loan repayment success rate vary by purpose?
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

-- 5.3 Which loan purposes contribute the most to bad loans?
SELECT DISTINCT purpose,
ROUND( (SUM(
		CASE 
			WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) 
            OVER (PARTITION BY purpose) / (SELECT COUNT(*) FROM bank_data WHERE loan_status = 'Charged Off')) *100,2)
as percentage_of_bad_loans
FROM bank_data
ORDER BY percentage_of_bad_loans DESC;

-- 6. Home Ownership Analysis
-- 6.1 How does home ownership status impact the likelihood of timely payments?
SELECT home_ownership,
SUM(CASE WHEN loan_status IN ('Fully paid','Current') THEN 1 ELSE 0 END) as No_of_good_loans,
SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) as No_of_bad_loans,
COUNT(*) as Total_loans,
ROUND( SUM(CASE WHEN loan_status IN ('Fully paid','Current') THEN 1 ELSE 0 END)*100 / COUNT(*) ,2) as Timely_payment_percentage
FROM bank_data
GROUP BY home_ownership
ORDER BY Timely_payment_percentage DESC;
-- Not a significant impact on loan repayment

-- 6.2 What percentage of loan applicants are homeowners, renters, or have a mortgage?
SELECT b.home_ownership, b.total_loans, b.total_loans*100 / a.overall_loans as percentage_of_loans
FROM
(SELECT COUNT(*)  as overall_loans
FROM bank_data) AS a
CROSS JOIN
(SELECT home_ownership, COUNT(*) as total_loans
FROM bank_data
GROUP BY home_ownership) AS b;

-- 6.3 How do the average loan amounts and repayment success differ by home ownership status?
SELECT home_ownership, 
ROUND(AVG(loan_amount)/1000,2) as avg_loan_amount_in_k$,
ROUND(COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN 1 END) * 100.0 / COUNT(*),2) AS repayment_success_rate
FROM bank_data
GROUP BY home_ownership
ORDER BY repayment_success_rate DESC;



-- 7. Loan Status Breakdown:

-- 7.1 How many loans have been paid off, are pending, or have been charged off?
SELECT DISTINCT loan_status , COUNT(*) OVER (PARTITION BY loan_status) as no_of_applications
FROM bank_data
ORDER BY no_of_applications DESC;

-- 7.2 What are the repayment trends over the past year(s)?
SELECT 
    YEAR(last_payment_date) AS year,
    COUNT(CASE WHEN loan_status = 'Fully Paid' THEN 1 END) * 100.0 / COUNT(*) AS repayment_success_rate,
    SUM(total_payment) AS total_repayment_amount
FROM bank_data
WHERE  last_payment_date IS NOT NULL 
GROUP BY YEAR(last_payment_date)
ORDER BY year;


-- 8. Annual Income vs. Loan Amount:
-- 8.1 What is the correlation between annual income and the average loan amount taken?
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
-- Not much correlaion between these columns that means higher or lower income doesn't effect the loan amount taken.

-- 8.2 How many borrowers have taken loans higher than a set multiple of their annual income?
SELECT
CASE WHEN multiples >= 0.8 THEN "0.8x more than annual_income"
	WHEN multiples >= 0.5 AND multiples < 0.8 THEN "0.5x more than annual_income"
    ELSE "Less than 0.5x annual_income"
    END as multiple_more_than_income,
COUNT(*)
FROM (
SELECT loan_amount/annual_income as multiples from bank_data) as loan_multiples
GROUP BY multiple_more_than_income;
-- Most of the people take less than 50% of annual_income as loan_amount

-- 8.3 


