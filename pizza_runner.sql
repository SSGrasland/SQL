-- How many pizzas were ordered? 
SELECT COUNT(*) AS Total_pizzas
FROM customer_orders;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_ID) AS Distinct_Orders
FROM customer_orders;

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*)
FROM runner_orders
WHERE pickup_time != 'null'
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
SELECT pizza_name, count(*)
FROM customer_orders as co
JOIN runner_orders as ro ON co.order_id = ro.order_id
JOIN pizza_names as pn ON co.pizza_id = pn.pizza_id
WHERE pickup_time != 'null'
GROUP BY 1;

--How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_id, count(pizza_id),  
FROM customer_orders
GROUP BY pizza_id, customer_id
ORDER BY customer_id;

--What was the maximum number of pizza delivered in a single order?
SELECT count(r.order_id) AS Total_pizza
FROM runner_orders as r 
JOIN customer_orders as c ON r.order_id = c.order_id
GROUP BY runner_id, r.order_id
ORDER BY Total_pizza desc;

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes? 

SELECT *,
    CASE
        WHEN EXCLUSIONS IN ('2', '4', '6') THEN '1'
        WHEN EXTRAS IN ('1', '4', '5') THEN '1'
        ELSE ''
    END AS Change,
    COUNT(Change)
    
FROM customer_orders as c
JOIN runner_orders as r ON r.order_id = c.order_id
GROUP BY customer_id;
