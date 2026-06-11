/*
===============================================================================
Project: SQL Server Customer & Sales Analytics

Business Problem:
Find the customer(s) with the highest number of completed purchases within each product category.

Business Rationale:
Identifying highly engaged customers can support targeted retention and loyalty initiatives.

SQL Concepts:
- CTEs
- Aggregations
- DENSE_RANK()
- Window Functions
===============================================================================
*/

WITH valid_orders AS
(SELECT
	o.[Order ID],
	o.[Customer ID],
	o.[Customer Name],
	o.Category
FROM
	Orders AS o
LEFT JOIN
	[Returns] AS r
ON
	o.[Order ID] = r.[Order ID]
WHERE
	r.Returned IS NULL), -- INCLUDE ONLY ORDERS THAT WERE NOT RETURNED

customer_order_counts AS
(SELECT
	Category,
	[Customer ID],
	[Customer Name],
	COUNT([Order ID]) AS Order_Count
FROM
	valid_orders
GROUP BY
	Category,
	[Customer ID],
	[Customer Name]),

ranked_customers AS
(SELECT
	Category,
	[Customer ID],
	[Customer Name],
	Order_Count,
	DENSE_RANK() OVER(PARTITION BY Category ORDER BY Order_Count DESC) AS DR
FROM
	customer_order_counts)

SELECT
	Category,
	[Customer ID],
	[Customer Name],
	Order_Count
FROM
	ranked_customers
WHERE
	DR = 1
ORDER BY
	Order_Count DESC;