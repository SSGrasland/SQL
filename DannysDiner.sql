-- What is the total amount each customer spent at the restaurant 
SELECT customer_id, sum(price) as Total_Amount
FROM sales as s
Join menu as m ON s.product_id = m.product_id
group by customer_id;

--How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(order_date) as Total_Amount
FROM sales as s
group by customer_id;

--What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, COUNT(product_name) as total_ordered, 
FROM menu as m 
JOIN sales as s ON s.product_id = m.product_id
group by product_name
order by total_ordered desc
LIMIT 1;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id, 
    SUM(CASE product_name 
    WHEN 'sushi' THEN price * 20
    ELSE price * 10 
    END) as Points
FROM sales as s
JOIN menu as m ON s.product_id = m.product_id
GROUP BY customer_id;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id, 
    SUM(IFF(product_name = 'sushi', price *20, price *10)) as Points
FROM sales as s
JOIN menu as m ON s.product_id = m.product_id
GROUP BY customer_id;

-- 
SELECT *, 
    CAST(join_date as DATE),
    join_date::DATE,
    CAST(CAST(join_date as DATE) as VARCHAR)
FROM members
