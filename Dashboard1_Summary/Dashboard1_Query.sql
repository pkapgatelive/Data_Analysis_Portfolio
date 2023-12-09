-- Chekking top 1000 rows from the database. 

SELECT TOP (1000)
    [id]
      , [address_state]
      , [application_type]
      , [emp_length]
      , [emp_title]
      , [grade]
      , [home_ownership]
      , [issue_date]
      , [last_credit_pull_date]
      , [last_payment_date]
      , [loan_status]
      , [next_payment_date]
      , [member_id]
      , [purpose]
      , [sub_grade]
      , [term]
      , [verification_status]
      , [annual_income]
      , [dti]
      , [installment]
      , [int_rate]
      , [loan_amount]
      , [total_acc]
      , [total_payment]
FROM [Bank Loan DB].[dbo].[BankLoanData]


--- Total Loan Application

/*
Total Loan Applications: Calculate total loan applications received within a specified period. 
                        Monitor Month-to-Date (MTD) applications and track Month-over-Month (MoM) changes.
*/

use [Bank Loan DB];


Select count(id) as Total_Loan_Applications
from BankLoanData;




-- Total Funded Amount
/*
Track the total funds disbursed as loans. Monitor Month-to-Date (MTD) Total Funded Amount and 
analyze Month-over-Month (MoM) changes in this metric.
*/

-- We do have the data of 2021 and latest month of the total loan applicaiton
-- Hence, MTD(month to Date) Loan Applicaiton is:

Select count(id) as MTD_Total_Loan_Application
from BankLoanData
where Month(issue_date) = 12 AND Year(issue_date) = 2021;


-- For the future perspective we can use the following query as well:
Select count(id) as MTD_Total_Loan_Application
from BankLoanData
where (
Month(issue_date) = (select MAX(MONTH(issue_date))
    from BankLoanData)
    AND
    Year(issue_date) = (Select Max(YEAR(issue_date))
    from BankLoanData) );


------------------------------------------------------------------------------------------------------------------------------------
-- Same that can be dynamic with the functions:---------------------------
IF OBJECT_ID('MTD_Total_Loan_Applications', 'FN') IS NOT NULL
    DROP FUNCTION MTD_Total_Loan_Applications;
GO
CREATE FUNCTION MTD_Total_Loan_Applications
(
    @p_month INTEGER,
    @p_year INTEGER
)
RETURNS INT
AS
BEGIN
    DECLARE @v_loan_count INT;

    SELECT @v_loan_count = COUNT(id)
    FROM BankLoanData
    WHERE MONTH(issue_date) = @p_month AND YEAR(issue_date) = @p_year;

    RETURN @v_loan_count;
END;
GO
-- Example of calling the function
DECLARE @result INT;
-- Replace the values for the month and year as needed
SET @result = dbo.MTD_Total_Loan_Applications(11, 2021);
-- Display the result
SELECT @result AS MTD_Total_Loan_Applications;
------------------------------------------------------------------------------------------------------------------------------------


-- PREVIOUS MONTH TO DATE APPLICATIONS (PMTD)
--- TO Track over the changes in Month-Over-Month
-- Formula to calulate : (MTD-PMTD)
DECLARE @outcome_in_percentage_result INT;
SET @outcome_in_percentage_result =  (dbo.MTD_Total_Loan_Applications(12, 2021) - dbo.MTD_Total_Loan_Applications(11, 2021));
-- Display the result
SELECT @outcome_in_percentage_result AS MTD_Total_Loan_Applications;


-- **Total Funded Amount:**

/*
Total Funded Amount: Understanding the total amount of funds disbursed as loans is crucial. 
We also want to keep an eye on the MTD Total Funded Amount and analyse the Month-over-Month (MoM) 
changes in this metric.
*/
-- Current Month
Select sum(loan_amount) as MTD_Total_Funded_Amount
from BankLoanData
where MONTH(issue_date) = 12 and Year(issue_date) = 2021;

-- Previous Month
Select sum(loan_amount) as PMTD_Total_Funded_Amount
from BankLoanData
where MONTH(issue_date) = 11 and Year(issue_date) = 2021;



-- **Total Amount Received:**
/*Total Amount Received: Tracking the total amount received from borrowers is essential for 
assessing the bank's cash flow and loan repayment. We should analyse the Month-to-Date (MTD)
Total Amount Received and observe the Month-over-Month (MoM) changes.
*/
-- Current month
Select sum(total_payment) as MTD_Total_Amount_Recived
from BankLoanData
where MONTH(issue_date) = 12 and Year(issue_date) = 2021;

-- Previous Month
Select sum(total_payment) as PMTD_Total_Amount_Recived
from BankLoanData
where MONTH(issue_date) = 11 and Year(issue_date) = 2021;


-- **Average Interest Rate:**
/*Average Interest Rate: Calculating the average interest rate across all loans, 
MTD, and monitoring the Month-over-Month (MoM) variations in interest rates will 
provide insights into our lending portfolio's overall cost.
*/

-- Current Month
Select round(avg(int_rate)*100,2) as MTD_Average_Interest_Rate
from BankLoanData
where MONTH(issue_date) = 12 and Year(issue_date) = 2021;

-- Previous Month
Select round(avg(int_rate)*100,2) as MTD_Average_Interest_Rate
from BankLoanData
where MONTH(issue_date) = 11 and Year(issue_date) = 2021;


-- **Average Debt-to-Income Ratio (DTI):**
/*Average Debt-to-Income Ratio (DTI): Evaluating the average DTI for our borrowers helps us gauge 
their financial health. We need to compute the average DTI for all loans, MTD, and track
Month-over-Month (MoM) fluctuations.
*/
-- Current Month
Select round(avg(dti)*100,2) as MTD_Average_DTI
from BankLoanData
where MONTH(issue_date) = 12 and Year(issue_date) = 2021;

-- Previous Month
Select round(avg(dti)*100,2) as PMTD_Average_DTI
from BankLoanData
where MONTH(issue_date) = 11 and Year(issue_date) = 2021;

Select Loan_Status
from BankLoanData
group by loan_status;


-- Good Loan KPIs:
-- Good Loan Application Percentage: 
/* We need to calculate the percentage of loan applications classified as 'Good Loans.' 
This category includes loans with a loan status of 'Fully Paid' and 'Current.' */
-- Final Code

Select
    ((count(Case When loan_status in ('Fully Paid', 'Current')then id END)) * 100)
    /
    count(id) as "Good_Loan_Percentage"
from BankLoanData;

-- Good Loan Applications: 
/*Identifying the total number of loan applications falling under the 'Good Loan' category, 
which consists of loans with a loan status of 'Fully Paid' and 'Current.' */

-- Findal Code
Select
    count(id) as Good_Loan_Application
from
    BankLoanData
where 
    loan_status in ('Fully Paid', 'Current');


-- Good Loan Funded Amount: 
/*Determining the total amount of funds disbursed as 'Good Loans.' 
This includes the principal amounts of loans with a loan status of 'Fully Paid' and 'Current.'*/
Select sum(loan_amount) as Good_Loan_Funded_Amount
from BankLoanData
where loan_status in ('Fully Paid', 'Current');


-- Good Loan Total Received Amount: 
/*Tracking the total amount received from borrowers for 'Good Loans,' 
which encompasses all payments made on loans with a loan status of 'Fully Paid' and 'Current.'*/
Select sum(total_payment) as Good_Loan_Recived_Amount
from BankLoanData
where loan_status in ('Fully Paid', 'Current');


-- Bad Loan KPIs:
-- Bad Loan Application Percentage: 
/*Calculating the percentage of loan applications categorized as 'Bad Loans.' 
This category specifically includes loans with a loan status of 'Charged Off.'*/
Select
    ((count(Case When loan_status in ('charged Off')then id END)) * 100)
    /
    count(id) as "Bad_Loan_Percentage"
from BankLoanData;


-- Bad Loan Applications: 
/*Identifying the total number of loan applications categorized as 'Bad Loans,' 
which consists of loans with a loan status of 'Charged Off.'*/

Select
    count(id) as Bad_Loan_Application
from
    BankLoanData
where 
    loan_status in ('charged Off');

-- Bad Loan Funded Amount: 
/*Determining the total amount of funds disbursed as 'Bad Loans.'
This comprises the principal amounts of loans with a loan status of 'Charged Off.'*/
Select sum(loan_amount) as Bad_Loan_Funded_Amount
from BankLoanData
where loan_status in ('charged Off');


-- Bad Loan Total Received Amount: 
/*Tracking the total amount received from borrowers for 'Bad Loans,' 
which includes all payments made on loans with a loan status of 'Charged Off.'*/
Select sum(total_payment) as Bad_Loan_Recived_Amount
from BankLoanData
where loan_status in ('charged Off');



-- Loan Status Grid View
/* In order to gain a comprehensive overview of our lending operations and monitor the performance of 
loans, we aim to create a grid view report categorized by 'Loan Status.' 
This report will serve as a valuable tool for analysing and understanding the key indicators associated 
with different loan statuses. By providing insights into metrics such as 

'Total Loan Applications,' 
'Total Funded Amount,' 
'Total Amount Received,' 
'Month-to-Date (MTD) Funded Amount,' 
'MTD Amount Received,' 
'Average Interest Rate,' and 
'Average Debt-to-Income Ratio (DTI),' 

this grid view will empower us to make data-driven decisions and assess the health of our loan portfolio.*/
-- Query 1
Select 
loan_status,
count(id) as Total_Loan_Application,
sum(loan_amount) as Total_Loan_Amount,
sum(total_payment) as Total_amount_Recived,
round(avg(int_rate) * 100, 2) as Interest_rate,
round(avg(dti) * 100, 2) as DTI
from BankLoanData Group by loan_status;

-- Query 2
Select loan_status,
sum(total_payment) as MTD_Total_Amount_Recived,
sum(loan_amount) as MTD_total_Funded_Amount
from BankLoanData where Month(issue_date) = 12 and YEAR(issue_date) = 2021
Group by loan_status;
