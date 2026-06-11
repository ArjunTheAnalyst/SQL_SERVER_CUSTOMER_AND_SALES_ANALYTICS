/*
===============================================================================
Project: SQL Server Customer & Sales Analytics

Business Problem:
Identify the top 5 customers based on average annual profit generated from completed (non-returned) purchases.

Business Rationale:
Returned orders are excluded to focus on realized customer value and profitability.

SQL Concepts:
- CTEs
- Aggregations
- Date Functions
- Customer Lifetime Value Analysis
===============================================================================
*/

WITH valid_orders AS
(SELECT
	o.[Customer ID],
	o.[Customer Name],
	o.[Order Date],
	ROUND(o.Profit, 0) AS Profit
FROM
	Orders AS o
LEFT JOIN
	[Returns] AS r
ON
	o.[Order ID] = r.[Order ID]
WHERE
	r.Returned IS NULL), -- INCLUDE ONLY ORDERS THAT WERE NOT RETURNED

customer_lifetime_profit AS
(SELECT
	[Customer ID],
	[Customer Name],
	SUM(Profit) AS Lifetime_Profit
FROM
	valid_orders
GROUP BY
	[Customer ID],
	[Customer Name]),

customer_active_years AS
(SELECT
	[Customer ID],
	COUNT(DISTINCT YEAR([Order Date])) AS Active_Years -- COUNT THE NUMBER OF DISTINCT YEARS IN WHICH THE CUSTOMER PLACED ATLEAST ONE UNRETURNED ORDER
FROM
	valid_orders
GROUP BY
	[Customer ID])

SELECT TOP 5
	clp.[Customer ID],
	clp.[Customer Name],
	ROUND(
	clp.Lifetime_Profit / cay.Active_Years, 0) AS Average_Annual_Profit
FROM
	customer_lifetime_profit AS clp
INNER JOIN
	customer_active_years AS cay
ON
	clp.[Customer ID] = cay.[Customer ID]
ORDER BY
	Average_Annual_Profit DESC;