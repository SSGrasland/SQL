/* A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions 
table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some 
sort of join to make your explanations a bit easier! */

SELECT customer_id, plan_name, price, start_date
FROM subscriptions as S 
INNER JOIN plans as P ON s.plan_id = p.plan_id
WHERE customer_id <= 8
LIMIT 100;

/* How many customers has Foodie-Fi ever had? */

SELECT COUNT(distinct customer_id) as customer_count
FROM subscriptions;

/* What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value */ 

SELECT 
DATE_TRUNC('month', start_date) AS month,
count(customer_id) as trial_starts
FROM subscriptions 
WHERE plan_id = 0
GROUP BY 1
LIMIT 100;

/* What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name */

SELECT plan_name, count(*)
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE start_date > '2020-12-31'
GROUP BY 1; 

/* What is the customer count and percentage of customers who have churned rounded to 1 decimal place? */

WITH customer_count AS (

SELECT COUNT(*) as all_count
FROM subscriptions ),

customer_churn AS (SELECT COUNT(*) as churn_count
FROM subscriptions 
WHERE plan_id = 4) 

SELECT customer_count.all_count, customer_churn.churn_count,
ROUND((customer_churn.churn_count::numeric / customer_count.all_count::numeric) * 100, 1) AS churn_percentage
FROM customer_count, customer_churn;

/* How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number? */


WITH CTE AS (
SELECT 
customer_id,
plan_name,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date ASC) as rn
FROM subscriptions as s 
INNER JOIN plans p on s.plan_id = p.plan_id)

SELECT COUNT(DISTINCT customer_id) as churned_after_trial,
ROUND((count(distinct customer_id) / (SELECT count(distinct customer_id) FROM subscriptions))*100, 1) as percent_churn_after_trail
FROM CTE
WHERE rn = 2
AND plan_name = 'churn'
;

/*What is the number and percentage of customer plans after their initial free trial?*/


WITH Plan_1 AS (
SELECT COUNT(*) as Plan_1_count
FROM subscriptions
WHERE plan_id = 1
),

plan_2 AS (
SELECT COUNT(*) as plan_2_count
FROM subscriptions
WHERE plan_id = 2
),

plan_3 AS (
SELECT COUNT(*) as plan_3_count
FROM subscriptions
WHERE plan_id = 3
),

plan_4 AS (
SELECT COUNT(*) as plan_4_count
FROM subscriptions
WHERE plan_id = 4
),

plan_total AS (
SELECT COUNT(*) as plan_all
FROM subscriptions
)

select *, 
ROUND((plan_4.plan_4_count::numeric/plan_total.plan_all::numeric)*100, 1) as Plan_4_percentage,
ROUND((plan_3.plan_3_count::numeric/plan_total.plan_all::numeric)*100, 1) as Plan_3_percentage,
ROUND((plan_2.plan_2_count::numeric/plan_total.plan_all::numeric)*100, 1) as Plan_2_percentage

FROM plan_2, plan_3, plan_4, plan_total
;

/* What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31? */

WITH CTE AS(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY start_date DESC) as rn
FROM subscriptions
WHERE start_date <= '2020-12-31'
)

SELECT 
plan_name, 
COUNT(customer_id) as customer_count,
ROUND((COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM CTE)) *100,1) as percent_of_customers
FROM CTE 
JOIN plans p on CTE.plan_id = p.plan_id
WHERE rn= 1 
GROUP BY plan_name;

/*How many customers have upgraded to an annual plan in 2020?*/

WITH annual AS (
Select plan_id
FROM plans
WHERE plan_id = 3
),

sub_2020 AS (
SELECT s.customer_id, s.plan_id, s.start_date, p.plan_name
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id 
WHERE EXTRACT(YEAR FROM s.start_date) = 2020
),

cupgrade AS ( 
SELECT customer_id, MIN(start_date) as first
FROM sub_2020
WHERE plan_id IN (SELECT plan_id FROM annual)
GROUP BY customer_id),

previous_plans AS (
SELECT DISTINCT 
s.customer_id
FROM subscriptions s
JOIN cupgrade u on s.customer_id = u.customer_id
WHERE s.start_date < u.first
)

SELECT 
COUNT(DISTINCT u.customer_id) AS upgrade_annual
FROM cupgrade u 
JOIN previous_plans pp ON u.customer_id = pp.customer_id
;
