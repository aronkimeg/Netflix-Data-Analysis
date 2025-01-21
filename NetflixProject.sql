/*
Title: Netflix Business Questions and Solutions (2023)
Author: Aron Kim
Date: 01/17/25

PROJECT DESCRIPTION:
This projects finds solutions for 16 real business questions that Netflix may have using the data from 2023. 
*/



-- Checking to see if dataframe is properly working4
SELECT *
FROM df;




-- 1.Question: What is the total monthly revenue generated across all users?
-- The total monthly revenue that Netflix is making is $31,271.

SELECT
	SUM(monthly_revenue) AS total_revenue
FROM df;

SELECT
	CONCAT('$', SUM(monthly_revenue)) AS total_monthly_rev      -- Adding the $ sign in front of the result.
FROM df;


-- 2.Question: What is the distribution of users by Subscription Type?
-- The basic subscription has the most user with 999, then standard with 768, and then premium with 733. 

SELECT 
	subscription_type,
	count(user_id) as user_amount
FROM df
GROUP BY subscription_type
ORDER BY user_amount DESC;


-- 3.Question: What is the average age of users by country?
-- Brazil seems to have the lowest average age at 38.33 and the United Kingdom seems to have the heighest at 39.19

SELECT 
	country,
	ROUND(AVG(age), 2) as avg_age
FROM df
GROUP BY country
ORDER BY avg_age ASC;


-- 4.Question: What percentage of users use a specific device?
-- The devices that are being used to stream Netflix shows are well spread out. It ranges from 24.40% to 25.44%

SELECT 
	count(user_id) AS id_count, 
	device,
	CONCAT(ROUND(COUNT(user_id) * 100/ SUM(COUNT(user_id)) OVER(), 2), '%') AS percent_device
FROM df
GROUP BY device
ORDER BY id_count ASC;


-- 5.Question: What is the most popular Plan Duration?
-- It seems like the only plan duration that is being used is the 1 month plan.

SELECT
	count(plan_duration)	
FROM df
GROUP BY plan_duration;


-- 6.Question: Which countries have the highest number of users?
-- The country with the highest number of users is the United States(451) and Spain (451). The lowest is the United Kingdom(183) and Australia(183).

SELECT
	country,
	count(user_id) as users
FROM df
GROUP BY country
ORDER BY users ASC;


-- 7.Question: Which countries generate the highest monthly revenue?
-- The top two countries that were generating the highest monthly revenues are the United States($5664) and Spain($5662). The Lowest were Mexico($2237) and Germany($2260).

-- Based on the previous question it makes sense that a higher user count is connected to a higher generated revenue for each country. 
-- An interesting fact is that though United Kingdom and Australia have the lowest user amount, Mexico and Germany have the lowest monthly revenue.
-- The only explanation from the dataframe is the different subscription plans.
-- Let's see if the subscription plan is the actual reason.

SELECT
	country,
	CONCAT('$',SUM(monthly_revenue)) as sum_monthly_rev
FROM df
GROUP BY country
ORDER BY sum_monthly_rev asc;


-- 8. Question: How many premiums, standard, and basic subscription does each country have?
-- The results prove that my hypothesis on subscription type was correct.
-- Mexico and  Germany had one highest amounts of basic and standard subscriptions while having the lowest premium subscriptions.

SELECT
	country,
	COUNT(CASE WHEN subscription_type = 'Basic' THEN 1 END) as basic_sub,
	COUNT(CASE WHEN subscription_type = 'Standard' THEN 1 END) as standard_sub,
	COUNT(CASE WHEN subscription_type = 'Premium' THEN 1 END) as premium_sub
FROM df
GROUP BY country
ORDER BY country;


-- 9.Question: What subscription types are most popular in each country?
-- I have successfully found the amount of subscription types that each country has.

SELECT
	country,
	subscription_type,
	count(user_id) as num_users
FROM df
GROUP BY country, subscription_type
ORDER BY country, subscription_type DESC;


-- 10.Question: How many users joined in 2021 (Join_Date) and are still active in July of 2023?
-- There are a total of 14 people who created a Netflix account in 2021 that are still active in July of 2023. This is a low number!

SELECT
	COUNT(user_id) AS active_2021
FROM df
WHERE
	EXTRACT(YEAR FROM join_date) = 2021
	AND last_payment_date >= '01-07-23';

-- There is a problem where the 'last_payment_date' and 'join_date' columns are text columns and not datetime.
-- I am going to need to convert it to proceed with finding the solution.

ALTER TABLE df
ALTER COLUMN join_date TYPE DATE USING TO_DATE(join_date, 'DD-MM-YY');

ALTER TABLE df
ALTER COLUMN last_payment_date TYPE DATE USING TO_DATE(last_payment_date, 'DD-MM-YY');

-- The data type of the columns are now changed so I will try using the code again.

SELECT
	COUNT(user_id) AS active_2021
FROM df
WHERE
	EXTRACT(YEAR FROM join_date) = 2021
	AND last_payment_date >= '01-07-23';


-- 11.Question: What is the average number of months that people paid for the monthly subscription?
-- Each user subscribes for about 9.68 months on average.

-- Code Explanation:
-- The age(last_payment_date, join_date) part of the code finds the difference for each user.
-- I multiply the DATE_PART 'year' by 12 because I want to see how many MONTHS on average that each user is subscribing for.
-- So once I convert the years into months I add it with months to see the total months each user subscribed for.

-- The previous question had such a low turnout rate, and I think it is important for the business to question why it is so low.

SELECT
	AVG(
        DATE_PART('year', age(last_payment_date, join_date)) * 12 +
        DATE_PART('month', age(last_payment_date, join_date))
    ) AS average_months_paid
FROM df;


-- 12.Question: What is the revenue distribution by gender?
-- It seems like gender does not make a very big difference in the total revenue.
-- A revenue of $15,535 was made from men and $15,736 from women.

SELECT
	gender,
	CONCAT('$',SUM(monthly_revenue)) as total_revenue
FROM df
GROUP BY gender
ORDER BY total_revenue ASC;


-- 13.Question: What is the revenue contribution of each Subscription Type?
-- Basic had the highest revenue contribution wITH $12,469 and Premium had the least with $9,229.

SELECT
	subscription_type,
	CONCAT('$', SUM(monthly_revenue)) as contribution
FROM df
GROUP BY subscription_type
ORDER BY contribution ASC;


-- 14.Question: What is the age distribution of users across subscription types?
-- People in the 30s seem to have the most subscriptions, while there seems to be little to no data on 20s.

SELECT
	count(subscription_type) as num_subscription,
	age
FROM df
GROUP BY age
ORDER BY num_subscription ASC;


-- 15.Question: How many users make regular payments versus irregular payments?
-- There are 399 regular payments compared to 2101 irregular payments.

-- This checks out as the total should be 2500 users, and that is the correct sum.
-- This means that the majority of people do not pay every month, but rather during times that they actually have time to watch shows.

-- Finding the regular payments of people who pay wihin a one month gap
SELECT
	COUNT(user_id) as reg_payments
FROM df
WHERE
	DATE_PART('month', age(last_payment_date, join_date)) <= 1
	AND last_payment_date IS NOT NULL;


SELECT
	COUNT(user_id) as irreg_payments
FROM df
WHERE
	DATE_PART('month', age(last_payment_date, join_date)) > 1
	AND last_payment_date IS NOT NULL;


-- 16.Question: What is the projected revenue for the next month based on current active users?
-- The projected revenue for the month of August of 2023 is $27,978.

SELECT
	CONCAT('$', sum(monthly_revenue)) as next_projected_rev
FROM df
WHERE
	last_payment_date >= '2023-06-10' AND last_payment_date <= '2023-07-10';

