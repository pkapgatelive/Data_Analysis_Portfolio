DECLARE
    @InputYear INT = 2021,
    @CurrentMonth INT = 1;

WHILE @CurrentMonth <= 12
BEGIN
    DECLARE
        @Total_Loan_Application INT,
        @Total_Funded_Amount DECIMAL(18, 2),
        @Total_Amount_Received DECIMAL(18, 2),
        @Average_Interest_Rate DECIMAL(18, 2),
        @Average_DTI DECIMAL(18, 2);

    -- Call the stored procedure for the current month
    EXEC Dashboard1_KPI
        @P_InputMonth = @CurrentMonth,
        @P_InputYear = @InputYear,
        @P_Total_Loan_Application = @Total_Loan_Application OUTPUT,
        @P_Total_Funded_Amount = @Total_Funded_Amount OUTPUT,
        @P_Total_Amount_Received = @Total_Amount_Received OUTPUT,
        @P_Average_Interest_Rate = @Average_Interest_Rate OUTPUT,
        @P_Average_DTI = @Average_DTI OUTPUT;

    -- Insert the results into the DashboardNovResults table
    INSERT INTO DashboardNovResults (
        Month_Name,
        Year_Name,
        Total_Loan_Application,
        Total_Funded_Amount,
        Total_Amount_Received,
        Average_Interest_Rate,
        Average_DTI
    )
    VALUES (
        @CurrentMonth,
        @InputYear,
        @Total_Loan_Application,
        @Total_Funded_Amount,
        @Total_Amount_Received,
        @Average_Interest_Rate,
        @Average_DTI
    );

    SET @CurrentMonth = @CurrentMonth + 1;
END



Select * from DashboardNovResults