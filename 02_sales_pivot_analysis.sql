/*
===============================================================================
Project: SQL Server Customer & Sales Analytics

Business Problem:
Create a category and sub-category sales report using both static and dynamic pivoting techniques.

Business Rationale:
Pivot reports provide management with a summarized view of sales distribution across product groups.

SQL Concepts:
- Conditional Aggregation
- PIVOT
- Dynamic SQL
- STRING_AGG
- QUOTENAME
===============================================================================
*/

-- APPROACH 1
WITH valid_orders AS
(SELECT
	o.Category,
	o.[Sub-Category],
	ROUND(o.Sales, 0) AS Sales
FROM
	Orders AS o
LEFT JOIN
	[Returns] AS r
ON
	o.[Order ID] = r.[Order ID]
WHERE
	r.Returned IS NULL) -- INCLUDE ONLY ORDERS THAT WERE NOT RETURNED

SELECT
	Category,
	SUM(CASE WHEN [Sub-Category] LIKE 'Accessories' THEN Sales END) AS Accessories,
	SUM(CASE WHEN [Sub-Category] LIKE 'Appliances' THEN Sales END) AS Appliances,
	SUM(CASE WHEN [Sub-Category] LIKE 'Art' THEN Sales END) AS Art,
	SUM(CASE WHEN [Sub-Category] LIKE 'Binders' THEN Sales END) AS Binders,
	SUM(CASE WHEN [Sub-Category] LIKE 'Bookcases' THEN Sales END) AS Bookcases,
	SUM(CASE WHEN [Sub-Category] LIKE 'Chairs' THEN Sales END) AS Chairs,
	SUM(CASE WHEN [Sub-Category] LIKE 'Copiers' THEN Sales END) AS Copiers,
	SUM(CASE WHEN [Sub-Category] LIKE 'Envelopes' THEN Sales END) AS Envelopes,
	SUM(CASE WHEN [Sub-Category] LIKE 'Fasteners' THEN Sales END) AS Fasteners,
	SUM(CASE WHEN [Sub-Category] LIKE 'Furnishings' THEN Sales END) AS Furnishings,
	SUM(CASE WHEN [Sub-Category] LIKE 'Labels' THEN Sales END) AS Labels,
	SUM(CASE WHEN [Sub-Category] LIKE 'Machines' THEN Sales END) AS Machines,
	SUM(CASE WHEN [Sub-Category] LIKE 'Paper' THEN Sales END) AS Paper,
	SUM(CASE WHEN [Sub-Category] LIKE 'Phones' THEN Sales END) AS Phones,
	SUM(CASE WHEN [Sub-Category] LIKE 'Storage' THEN Sales END) AS Storage,
	SUM(CASE WHEN [Sub-Category] LIKE 'Supplies' THEN Sales END) AS Supplies,
	SUM(CASE WHEN [Sub-Category] LIKE 'Tables' THEN Sales END) AS [Tables]
FROM
	valid_orders
GROUP BY
	Category
ORDER BY
	Category;


-- APPROACH 2 (HINT: RUN ALL AT ONCE)
DECLARE @pivot_columns NVARCHAR(MAX); -- STORES DYNAMIC LIST OF SUB-CATEGORY COLUMNS
DECLARE @pivot_query NVARCHAR(MAX); -- STORES THE ENTIRE DYNAMIC SQL QUERY

-- STEP 1: GENERATE DYNAMIC COLUMN LIST
SELECT
	@pivot_columns =  STRING_AGG(QUOTENAME([Sub-Category]), ', ') WITHIN GROUP (ORDER BY [Sub-Category])
FROM
	(SELECT DISTINCT([Sub-Category]) FROM Orders) AS distinct_subcategories;

-- STEP 2: BUILD DYANMIC PIVOT QUERY
SET @pivot_query =
'
WITH valid_orders AS
(SELECT
	o.Category,
	o.[Sub-Category],
	ROUND(
	o.Sales, 0) AS Sales
FROM
	Orders AS o
LEFT JOIN
	[Returns] AS r
ON
	o.[Order ID] = r.[Order ID]
WHERE
	r.Returned IS NULL),

sales_per_sub_category AS
(SELECT
	Category,
	[Sub-Category],
	SUM(Sales) AS Total_Sub_Category_Sales
FROM
	valid_orders
GROUP BY
	Category,
	[Sub-Category])

SELECT
	*
FROM
	sales_per_sub_category
PIVOT
	(
	SUM(Total_Sub_Category_Sales)
	FOR [Sub-Category] IN ('+ @pivot_columns +')
	) AS Sub_Category_Pivot
ORDER BY
	Category;
'

-- STEP 3: EXECUTE DYNAMIC SQL STATEMENT
EXEC SP_EXECUTESQL @pivot_query;