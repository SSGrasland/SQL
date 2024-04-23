SELECT *
FROM orders;

--Return the first 100 records from Orders table 
SELECT * 
FROM orders
LIMIT 100;

--Retrun all Product IDs in the Order Tables
SELECT product_id
FROM orders;

--Return a list of distinct Product IDs in the Orders table
SELECT DISTINCT product_id
FROM orders;

--Return a unique combination of Product IDs and Ship Mode in the Orders table 
SELECT DISTINCT product_ID, ship_mode 
FROM orders;

--Rename Ship_Mode to "available shipping"
SELECT DISTINCT product_id, ship_mode as available_shipping 

FROM orders as o;

-- Retrun a unique list 
SELECT DISTINCT product_name, ship_mode
FROM orders as o JOIN PRODUCTS AS p ON o.product_id = p.product_id;

-- Return a list of all orders, with a column showing which orders were returned 
SELECT * 
FROM returned_orders;

SELECT DISTINCT o.order_id, returned, 
FROM orders as o LEFT JOIN returned_orders as r ON  o.order_id = r.order_id;

-- Return a list of all sales repts and customers 

SELECT SALES_PERSON_FULLNAME, CUSTOMER_NAME
FROM CUSTOMERS as c 
    FULL OUTER JOIN CUSTOMER_SALES_REP as cs     
ON c.customer_id = cs.customer_id;

-- Return all orders from customers in the Central Region 

SELECT *, region
FROM orders as o
    INNER JOIN customers as c ON c.customer_id = o.customer_id
WHERE Region  = 'Central';

-- Return all unique states and product names in the Central Region 
SELECT DISTINCT product_name, state, region
FROM orders as o 
    join products as p ON o.product_id = p.product_id
    join customers as c on c.customer_id = o.customer_id
WHERE Region = 'Central';

-- retrn a list of unique customers region and cities from all regions except central 
SELECT DISTINCT customer_name, region, city
FROM orders as o 
join customers as c ON o.customer_id = c.customer_id
WHERE Region != 'Central';

-- return a unique list of prodcuts that srart with the ltter B
SELECT DISTINCT product_name
FROM products
WHERE product_name LIKE 'B%';

--
SELECT DISTINCT city
FROM customers
WHERE city LIKE '%town%';

--
SELECT DISTINCT city 
FROM customers
WHERE state IN ('Alabama', 'Georgia', 'Florda');

-- Retrun all orders containing products with quanitity greater than 1 and negative profit 
SELECT *
FROM orders
WHERE quantity > 1 AND profit < 0;

--
SELECT * 
FROM orders 
WHERE order_date BETWEEN '2019-01-01' AND '2019-12-31';

--number of unique products
SELECT COUNT(DISTINCT product_id)
from products;

--total quantity ordered 
SELECT SUM(Quantity) as "Total Quantity"
FROM orders;

--
SELECT product_id, 
    SUM(quantity) as "Total Quantity"
FROM orders
GROUP BY product_id;

-- 
SELECT COUNT(DISTINCT c.customer_ID), state, sales_person_fullname
FROM customer_sales_rep as csr 
join customers as c ON csr.customer_id = c.customer_id
group by state, sales_person_fullname;


--
SELECT MAX(o.discount), sum(o.profit), c.state
FROM orders as o
JOIN customers as c ON o.customer_id = c.customer_id
group by state
order by state;

--
SELECT order_date, SUM(profit) as total_profit 
from Orders
GROUP BY order_date
HAVING total_profit > 500;

--
SELECT DISTINCT state
from CUSTOMERS
ORDER BY state desc;

-- 
SELECT COUNT(DISTINCT customer_ID), state

from customers
GROUP BY state
ORDER BY COUNT(DISTINCT customer_ID) desc
LIMIT 1;

CREATE TABLE 
TIL_PLAYGROUND.TEMP.SG_2020_orders_table AS 
SELECT * 
FROM TIL_PLAYGROUND.SQL_COURSE.ORDERS
WHERE order_date BETWEEN '2020-01-01' AND '2020-12-31';

CREATE VIEW 
TIL_PLAYGROUND.TEMP.SG_2020_orders_view AS 
SELECT * 
FROM TIL_PLAYGROUND.SQL_COURSE.ORDERS
WHERE order_date BETWEEN '2020-01-01' AND '2020-12-31';

--
SELECT *
FROM TIL_PLAYGROUND.TEMP.SG_2020_ORDERS_TABLE;

--
SELECT * 
FROM   TIL_PLAYGROUND.TEMP.SG_2020_ORDERS_VIEW;

--
SELECT DRIVERID, forename, surname
FROM DRIVERS;

SELECT r.driverid, forename, surname, fastestlapspeed
FROM DRIVERS as d
JOIN RESULTS AS r ON d.driverid = r.driverid
WHERE fastestlapspeed IS NOT null;

--

SELECT d.driverid, forename, surname, name as race_name, year as race_year, MAX(FASTESTLAPSPEED) as FastestLapSpeed2021
FROM drivers as d
JOIN results as r ON d.driverid = r.driverid
JOIN RACES AS ra ON r.raceid = ra.raceid
WHERE year = '2021' and name ILIKE '%Monaco%'
GROUP BY 1, 2, 3, 4, 5;

-- Return the list of drivers  and fastest lap speed of all time 

SELECT driverid, 
        forename,
        surname,
        (select MAX(fastestlapspeed) FROM results) as FastestLapSpeedAllTime
FROM drivers;

-- Return the list of drivers and their fastest lap speed in Monaco in 2021, as well as the fastest lap speed of all time

SELECT d.driverid, forename, surname, name as race_name, year as race_year, MAX(FASTESTLAPSPEED) as FastestLapSpeed2021, (select MAX(fastestlapspeed) FROM results) as FastestLapSpeedAllTime
FROM drivers as d
JOIN results as r ON d.driverid = r.driverid
JOIN RACES AS ra ON r.raceid = ra.raceid
WHERE name ILIKE '%Monaco%'AND year = 2021
GROUP BY 1, 2, 3, 4, 5;

--Return the list of drivers, their fastest lap speed in Monaco in 2021, as well as how many times they have won in Monaco in total (use driver_standings table to workout previous wins)

SELECT d.driverid, 
        forename, 
        surname, 
        name as race_name,  
        MAX(FASTESTLAPSPEED) as FastestLapSpeed2021, 
        TotalWinsInMonaco
FROM drivers as d
    JOIN results as r ON d.driverid = r.driverid
    JOIN driver_standings as ds ON d.driverid = ds.driverid
    JOIN races AS ra ON r.raceid = ra.raceid
    JOIN (SELECT driverid, 
        SUM(wins) as TotalWinsInMonaco
        FROM driver_standings as ds
        JOIN races as ra ON ra.raceid = ds.raceid
        WHERE name ILIKE '%Monaco%'
        GROUP BY driverid) as w
        ON w.driverid = d.driverid

WHERE year = '2021' and name ILIKE '%Monaco%'
GROUP BY d.driverid, 
        forename, 
        surname, 
        race_name,   
        TotalWinsInMonaco;

--
SELECT driverid, 
        SUM(wins) as TotalWinsInMonaco
FROM driver_standings as ds
        JOIN races as ra ON ra.raceid = ds.raceid
WHERE name ILIKE '%Monaco%'
GROUP BY driverid;

--
WITH w as (SELECT driverid, 
        SUM(wins) as TotalWinsInMonaco
        FROM driver_standings as ds
        JOIN races as ra ON ra.raceid = ds.raceid
        WHERE name ILIKE '%Monaco%'
        GROUP BY driverid)
        
SELECT d.driverid, 
        forename, 
        surname, 
        name as race_name,  
        MAX(FASTESTLAPSPEED) as FastestLapSpeed2021, 
        TotalWinsInMonaco
        
FROM drivers as d
    JOIN results as r ON d.driverid = r.driverid
    JOIN driver_standings as ds ON d.driverid = ds.driverid
    JOIN races AS ra ON r.raceid = ra.raceid
    JOIN w ON w.driverid = d.driverid

WHERE year = '2021' and name ILIKE '%Monaco%'
GROUP BY d.driverid, 
        forename, 
        surname, 
        race_name,   
        TotalWinsInMonaco;

-- 

WITH list_of_dates as (select date('2024-03-18') as date
                UNION ALL 
                SELECT DATEADD('day', 1, date) as date
                FROM list_of_dates
                WHERE DATEADD('day', 1, date) <= DATE('2024-03-24'))
SELECT date 
FROM list_of_dates;

--

SELECT d.driverid, forename, surname, name as race_name, year as race_year, MAX(FASTESTLAPSPEED) as FastestLapSpeed2021
FROM drivers as d
JOIN results as r ON d.driverid = r.driverid
JOIN RACES AS ra ON r.raceid = ra.raceid
WHERE year = '2021' and name ILIKE '%Monaco%'
GROUP BY 1, 2, 3, 4, 5;

SELECT d.driverid, year as race_year, MAX(FASTESTLAPSPEED) as FastestLapSpeed2021
FROM drivers as d
JOIN results as r ON d.driverid = r.driverid
JOIN RACES AS ra ON r.raceid = ra.raceid
WHERE year = '2019' and name ILIKE '%Monaco%'
GROUP BY 1, 2;

--

WITH nineteen as    (SELECT d.driverid, 
                      name as race_name, 
                      year as race_year, 
                      MAX(FASTESTLAPSPEED) as FastestLapSpeed2019
                      FROM drivers as d
                        JOIN results as r ON d.driverid = r.driverid
                        JOIN RACES AS ra ON r.raceid = ra.raceid
                      WHERE year = '2019' and name ILIKE '%Monaco%'
                      GROUP BY 1, 2, 3),


    twentyone as    (SELECT d.driverid, 
                     forename, 
                     surname, 
                     name as race_name, 
                     year as race_year, 
                     MAX(FASTESTLAPSPEED) as FastestLapSpeed2021
                    FROM drivers as d
                    JOIN results as r ON d.driverid = r.driverid
                    JOIN RACES AS ra ON r.raceid = ra.raceid
                    WHERE year = '2021' and name ILIKE '%Monaco%'
                    GROUP BY 1, 2, 3, 4, 5)

SELECT n.driverid,
       t.forename,
       t.surname, 
       FastestLapSpeed2019,
       FastestLapSpeed2021
        
FROM nineteen as n
    JOIN twentyone  as t ON n.driverid = t.driverid;


