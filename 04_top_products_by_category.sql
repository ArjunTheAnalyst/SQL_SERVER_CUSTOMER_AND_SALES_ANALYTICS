/*
===============================================================================
Project: SQL Server Customer & Sales Analytics

Business Problem:
Identify the top three products within each category based on completed sales.

Business Rationale:
Understanding top-performing products supports inventory planning, marketing efforts, and product strategy.

SQL Concepts:
- CTEs
- Window Functions
- DENSE_RANK()
- Product Performance Analysis
===============================================================================
*/

WITH valid_orders AS
(SELECT
	o.Category,
	o.[Product ID],
	o.[Product Name],
	ROUND(
	o.Sales, 0) AS Sales
FROM
	Orders AS o
LEFT JOIN
	[Returns] AS r
ON
	o.[Order ID] = r.[Order ID]
WHERE
	r.Returned IS NULL), -- INCLUDE ONLY ORDERS THAT WERE NOT RETURNED

product_sales AS
(SELECT DISTINCT
	Category,
	[Product ID],
	[Product Name],
	SUM(Sales) OVER(PARTITION BY Category, [Product ID], [Product Name]) AS Total_Sales
FROM
	valid_orders),

ranked_products AS
(SELECT
	Category,
	[Product ID],
	[Product Name],
	Total_Sales,
	DENSE_RANK() OVER(PARTITION BY Category ORDER BY Total_Sales DESC, [Product ID], [Product Name]) AS DR
FROM
	product_sales)

SELECT
	Category,
	[Product ID],
	[Product Name],
	Total_Sales
FROM
	ranked_products
WHERE
	DR <= 3;