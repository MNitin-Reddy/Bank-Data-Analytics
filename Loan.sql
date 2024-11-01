USE demo;

SELECT * FROM bank_data;

-- Total Number of Applications
SELECT COUNT(id) as total_loan_applications 
FROM bank_data;
-- we have 38,576 loan appliations

-- Total funded amount
SELECT sum(loan_amount)/1000000 as total_funded_amount_in_millions 
FROM bank_data;

-- Total payment received
SELECT sum(total_payment)/1000000 as total_payment_recieved_in_millions
FROM bank_data; 
-- 473 million

SELECT DISTINCT purpose from bank_data;

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
WHERE loan_status in ('Fully paid', 'Current')