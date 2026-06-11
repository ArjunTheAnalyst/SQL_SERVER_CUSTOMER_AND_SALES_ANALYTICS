/*
===============================================================================
Project: SQL Server Customer & Sales Analytics

Business Problem:
Create reusable SQL Server objects to retrieve customer-level KPIs.

Business Rationale:
Operational teams frequently require quick access to customer metrics for reporting and decision-making.

Metrics Returned:
- Most Recent Order Date
- Total Sales
- Total Orders
- Average Sales Per Order
- Days Since Last Order

SQL Concepts:
- Scalar User Defined Functions
- Stored Procedures
- Parameters
- Aggregate Functions
- Date Calculations
===============================================================================
*/

-- FUNCTION
DROP FUNCTION IF EXISTS DBO.DAYS_BETWEEN_DATES; -- FOR CLEAN RE-RUNS AND IDEMPOTENCY

CREATE FUNCTION DBO.DAYS_BETWEEN_DATES
(@START_DATE DATE, @END_DATE DATE)
RETURNS INT

AS BEGIN
	RETURN DATEDIFF(DAY, @START_DATE, @END_DATE);
END;


-- STORED PROCEDURE
DROP PROCEDURE IF EXISTS CUSTOMER_DETAILS; -- FOR CLEAN RE-RUNS AND IDEMPOTENCY

CREATE PROCEDURE CUSTOMER_DETAILS
@CUSTOMER_ID NVARCHAR(25)

AS BEGIN
	SELECT
		CAST(MAX(o.[Order Date]) AS DATE) AS Most_Recent_Order_Date,
		ROUND(
		SUM(o.Sales), 0) AS Total_Sales,
		COUNT(DISTINCT o.[Order ID]) AS Total_Order_Count,
		ROUND(
		SUM(o.Sales)
		/
		COUNT(DISTINCT o.[Order ID]), 0)
		AS Average_Sales_Per_Order,
		DBO.DAYS_BETWEEN_DATES(CAST(MAX(o.[Order Date]) AS DATE), CAST(GETDATE() AS DATE)) AS Days_Since_Last_Order
	FROM
		Orders AS o
	LEFT JOIN
		[Returns] AS r
	ON
		o.[Order ID] = r.[Order ID]
	WHERE
		r.Returned IS NULL
	AND
		o.[Customer ID] = @CUSTOMER_ID;
END;

EXEC CUSTOMER_DETAILS @CUSTOMER_ID = 'SC-20770';