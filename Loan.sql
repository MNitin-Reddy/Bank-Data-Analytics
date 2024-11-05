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
-- Bad -> 37.28

-- 2.4 What is the trend in the repayment behavior over time for good vs. bad loans?
SELECT 
    DATE_FORMAT(issue_date, '%Y-%m') AS month,
    SUM(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 ELSE 0 END) AS good_loans,
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END) AS bad_loans
FROM bank_data
GROUP BY month
ORDER BY month;








-- ---------------------------------------------------------


SELECT DISTINCT purpose from bank_data;

UPDATE `bank_data`
SET `issue_date` = STR_TO_DATE(`issue_date`, '%d-%m-%Y')
WHERE `issue_date` IS NOT NULL;

ALTER TABLE `bank_data` 
CHANGE COLUMN `issue_date` `issue_date` DATE NULL;


-- Avg interest rate for each type of loan
SELECT purpose, ROUND(avg(int_rate),3) as avg_int_rate
FROM bank_data
GROUP BY purpose
ORDER BY avg_int_rate DESC;

-- Calculate the avg dti which will be grouped by monthly basis for year 2021
SELECT YEAR(issue_date) as Year,
MONTH(issue_date) as Month,
ROUND(avg(dti),2) as avg_dti
FROM bank_data
WHERE YEAR(issue_date) = 2021
GROUP BY YEAR(issue_date), month(issue_date)
ORDER BY Month;

-- Good Loan vs Bad Loan
SELECT DISTINCT loan_status from bank_data;
-- Good Loan applications in %
SELECT COUNT(
CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN 'Good Loan'
	ELSE 'Bad Loan'
    END) as loan_type
FROM bank_data;

SELECT COUNT(
CASE when loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id end) * 100 / count(id)
AS good_loan_percentage from bank_data;

SELECT COUNT(*) as total_loan_applications, COUNT(
CASE WHEN loan_status in ('Fully paid', 'Current') then id end)
as good_loan_app 
FROM bank_data;

-- Total amount received in good loan applications
SELECT ROUND(SUM(total_payment)/1000000,2) as total_amount_received_in_millions
FROM bank_data
WHERE loan_status in ('Fully paid', 'Current');

--
-- Step 1: Add a new DATE column
ALTER TABLE bank_data DROP issue_date_new;

-- Step 2: Populate the new column by converting the old column format to DATE
UPDATE bank_data
SET issue_date_new = STR_TO_DATE(issue_date, '%d-%m-%Y')
WHERE 1;

-- Step 3: (Optional) Drop the old column
ALTER TABLE bank_data DROP COLUMN issue_date;

-- Step 4: Rename the new column to the original name
ALTER TABLE bank_data CHANGE issue_date_new issue_date DATE;



-- -------------

-- Month to Month total amount recieved
WITH monthlytotals AS(
SELECT year(issue_date) as year, month(issue_date) as month,
SUM(total_payment) as monthly_payment
FROM bank_data
WHERE year(issue_date) = 2021
group by year(issue_date), month(issue_date)
),
monthovermonth as (
SELECT year, month, monthly_payment as current_month_payment,
monthly_payment as previous_month_payment,
monthly_payment - monthly_payment as month_over_month_amt
FROM





