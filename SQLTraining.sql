// SQL Training/Refresher
select * from "Superstore_Orders";

SELECT DISTINCT "Region" FROM "Superstore_Orders";

SELECT * FROM "Superstore_Orders"
WHERE "State" = 'Florida'
AND "Segment" = 'Consumer';

SELECT * FROM "Superstore_Orders"
WHERE "State" IN('Florida', 'New York');

SELECT * FROM "Superstore_Orders"
WHERE "Sales" BETWEEN 200 AND 400;

SELECT * FROM "Superstore_Orders" 
WHERE "Product Name" LIKE 'B%';

Select * FROM "Superstore_Orders"
WHERE "Region" = 'East'
AND "Profit" > 200;

SELECT DISTINCT "Product Name"
FROM "Superstore_Orders"
WHERE "Region" IN('South', 'Central')
AND "Sales" BETWEEN 200 AND 300;

SELECT DISTINCT "Product Name"
FROM "Superstore_Orders"
WHERE "Product Name" LIKE '%b%';


SELECT * FROM "Superstore_Orders"
WHERE "Profit" < 0 AND "Region" IN('CENTRAL') OR "State" = 'New York';

SELECT "Sales"
FROM "Superstore_Orders"
ORDER BY "Sales" DESC
LIMIT 10; 

SELECT TOP 10 "Sales"
FROM "Superstore_Orders"
ORDER BY "Sales" DESC;

//SQL Training Week 2

SELECT "Region", SUM("Sales"), SUM("Profit")
FROM "Superstore_Orders"
GROUP BY "Region";


SELECT "Segment"
, "Ship Mode"
, AVG("Discount") Discount
FROM "Superstore_Orders"
GROUP BY "Segment", "Ship Mode"
ORDER BY Discount DESC;

// For the Central Region
// Find the Minimum Profit value per Sub-Category
// Alias the Minimum Profit field
// Order from lowest profit value to highest

SELECT "Sub-Category"
, MIN("Profit") Min_Profit
FROM "Superstore_Orders"
WHERE "Region" = 'Central'
GROUP BY "Sub-Category"
ORDER BY Min_Profit ASC;


//Which Order Dates had a total profit greater than 2000?
//Alias your profit aggregation
//Sort from highest to lowest profit

SELECT "Order Date"
, SUM("Profit") Profit 
FROM "Superstore_Orders"
GROUP BY "Order Date"
HAVING Profit > 2000
ORDER BY Profit DESC;

//For the Central Region, which Products had an average profit less than -400?
//Alias your profit aggregation
//Sort from lowest to highest avg profit

SELECT "Product Name"
, AVG("Profit") Profit 
FROM "Superstore_Orders"
WHERE "Region" = 'Central'
GROUP BY "Product Name"
HAVING Profit < -400 
ORDER BY Profit Asc;

// For Florida State in the Superstore_Joined table
// Find the total Sales value of items returned and not returned
// SUM(“Sales”)
// Find the total number of items returned and not returned
// COUNT(“Product Name”)
// Alias your fields

SELECT IFNULL("Returned", 'No') Returned
, SUM("Sales") Sales
, COUNT(Returned) Total_Returned
FROM "Superstore_Joined"
WHERE "State" = 'Florida'
GROUP BY Returned;

//For the Furniture Category in the Superstore_Joined table
//Find the top 10 order values for orders with a profit < 0
//Ensure the orders have not been returned
//Alias your fields

SELECT "Order ID"
, SUM("Profit") Profit 
, SUM("Sales") Sales 
FROM "Superstore_Joined"
WHERE "Category" = 'Furniture'
AND "Returned" IS NOT NULL
GROUP BY "Order ID"
HAVING Profit < 0 
ORDER BY Sales DESC
LIMIT 10;

// Join Superstore_Orders to Superstore_People using Region as the key. Alias the tables for ease.
SELECT * FROM "Superstore_Orders" AS SO
INNER JOIN "Superstore_People" AS SP
ON  SO."Region" = SP."Region";

//Join Superstore_Orders to Superstore_Returns, selecting all columns.
//First do an Inner Join
//Then do a Left Join
//Then a Right Join
//Does the output change? And how? Why is it changing?

SELECT * 
FROM "Superstore_Orders" AS SO 
RIGHT JOIN "Superstore_Returns" AS SR
ON SO."Order ID" = SR."Order ID";

//Change the schema you are using to the SQL_COURSE schema
USE SCHEMA SQL_COURSE;

//Join CUSTOMERS to CUSTOMER_SALES_REP
//Can you work out how many customers do not have a Sales representative? 
//HINT: Use a LEFT JOIN.

SELECT COUNT(*)
FROM "CUSTOMERS" AS C
LEFT JOIN "CUSTOMER_SALES_REP" AS CR 
ON C."CUSTOMER_ID" = CR."CUSTOMER_ID"
WHERE CR."CUSTOMER_ID" IS NULL;

// Ex 15 Part 2 How could we go about counting the number of customers with anD without a sales rep, creating a field to group them by?

SELECT 
(CASE WHEN S."CUSTOMER_ID" IS NULL THEN 'NO_SALES_REP'
            WHEN S."CUSTOMER_ID" IS NOT NULL THEN 'SALES_REP' END) AS SALES_REPS 
, COUNT(*)
FROM "CUSTOMERS" AS C
LEFT JOIN "CUSTOMER_SALES_REP" AS S
ON C."CUSTOMER_ID" = S."CUSTOMER_ID"
GROUP BY SALES_REPS;

// Execute the following two queries: 

USE DATABASE TIL_PLAYGROUND;
USE SCHEMA DSUS_SQL_WORKSHOP;

//Find the monthly % of total orders returned
//Which month shows the highest and lowest % of returned orders
//Find the running monthly total number of orders returned 

WITH CTE AS (
SELECT DATE_TRUNC(MONTH, S.ORDER_DATE) AS MONTH,
S.ORDER_ID,
IFNULL(R.RETURNED, 'No') AS RETURNED

FROM
SUPERSTORE S
LEFT JOIN 
(SELECT DISTINCT ORDER_ID, 
RETURNED
FROM RETURNED) R
ON S.ORDER_ID = R.ORDER_ID
)

,
YN AS (
SELECT MONTH, 
RETURNED, 
COUNT(DISTINCT ORDER_ID) AS CNT
FROM CTE
GROUP BY 1, 2
ORDER BY 1, 2
)
,
TOTAL AS (
SELECT MONTH, 
COUNT(DISTINCT ORDER_ID) AS TOTAL
FROM CTE
GROUP BY 1
ORDER BY 1)

SELECT YN.MONTH, 
CNT/TOTAL AS PERC_OF_TOTAL
FROM 
YN 
JOIN
TOTAL
ON YN.MONTH = TOTAL.MONTH
WHERE RETURNED = 'Yes';


//Execute the following two queries.
//USE DATABASE TIL_PLAYGROUND; 
//USE SCHEMA SQL_COURSE;
//Multiple tables required.

//Task:
//Using Profit, which salesperson performed the best in one quarter but also the worst in another quarter in 2020?
//There are 16 sales people.
//HINT: You’ll want to rank each salesperson for each quarter with respect to their total PROFIT generated.


SELECT 
sales_person_fullname as salesperson, 
quarter(order_date) as q, 
rank() over (partition by q order by sum(profit) desc) as rank,
sum(profit) as profit,

FROM CUSTOMER_SALES_REP csr
JOIN ORDERS o
ON csr.customer_id = o.customer_id
where year(order_date) =2020
GROUP BY 1, 2
ORDER BY Q, Rank;

// Creating CTE now that basic query is known

WITH CTE AS 
(SELECT 
sales_person_fullname as salesperson, 
quarter(order_date) as q, 
rank() over (partition by q order by sum(profit) desc) as rank,
sum(profit) as profit,

FROM CUSTOMER_SALES_REP csr
JOIN ORDERS o
ON csr.customer_id = o.customer_id
where year(order_date) =2020
GROUP BY 1, 2
ORDER BY Q, Rank) 

SELECT salesperson, 
MAX(RANK) as worst,
min(rank) AS best
FROM CTE 
GROUP BY 1
HAVING WORST = 16
AND BEST = 1;
