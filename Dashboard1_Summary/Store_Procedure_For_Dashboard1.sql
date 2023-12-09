USE [Bank Loan DB];

IF OBJECT_ID('Dashboard1_KPI', 'P') IS NOT NULL
    DROP PROCEDURE Dashboard1_KPI;

GO

CREATE PROCEDURE Dashboard1_KPI
    @P_InputMonth INT,
    @P_InputYear INT,
    @P_Total_Loan_Application INT OUTPUT,
    @P_Total_Funded_Amount DECIMAL(18, 2) OUTPUT,
    @P_Total_Amount_Received DECIMAL(18, 2) OUTPUT,
    @P_Average_Interest_Rate DECIMAL(18, 2) OUTPUT,
    @P_Average_DTI DECIMAL(18, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Total Loan Applications 
        SELECT @P_Total_Loan_Application = COUNT(id) 
        FROM BankLoanData 
        WHERE MONTH(issue_date) = @P_InputMonth AND YEAR(issue_date) = @P_InputYear;

        -- Total Funded Amount
        SELECT @P_Total_Funded_Amount = SUM(loan_amount) 
        FROM BankLoanData 
        WHERE MONTH(issue_date) = @P_InputMonth AND YEAR(issue_date) = @P_InputYear;

        -- Total Amount Received:
        SELECT @P_Total_Amount_Received = SUM(total_payment) 
        FROM BankLoanData 
        WHERE MONTH(issue_date) = @P_InputMonth AND YEAR(issue_date) = @P_InputYear;

        -- Average Interest Rate:
        SELECT @P_Average_Interest_Rate = ROUND(AVG(int_rate) * 100, 2) 
        FROM BankLoanData 
        WHERE MONTH(issue_date) = @P_InputMonth AND YEAR(issue_date) = @P_InputYear;

        -- Average Debt-to-Income Ratio (DTI):
        SELECT @P_Average_DTI = ROUND(AVG(dti) * 100, 2) 
        FROM BankLoanData 
        WHERE MONTH(issue_date) = @P_InputMonth AND YEAR(issue_date) = @P_InputYear;
    END TRY
    BEGIN CATCH
        -- Log the error or print a message
        PRINT 'An error occurred: ' + ERROR_MESSAGE();
    END CATCH
END;

