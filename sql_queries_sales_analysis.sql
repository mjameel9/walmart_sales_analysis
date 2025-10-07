CREATE DATABASE walmart_db;
USE walmart_db;

SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
	COUNT(*) AS nu_of_transactions
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch) AS nu_of_branches
FROM walmart;



-- Business Problem 1: Find different payment methods, number of transactions,
-- and quantity sold by payment method-- 
SELECT 
	payment_method,
	COUNT(*) AS nu_of_transactions,
    SUM(quantity) AS total_quantities_sold
FROM walmart
GROUP BY payment_method;



-- Business Problem 2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
SELECT branch, category, avg_rating
FROM (	
	SELECT
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rating_rank
	FROM walmart
	GROUP BY branch, category
	) AS ranks
WHERE rating_rank = 1;



-- Business Problem 3: Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, nu_of_transactions
FROM (
	SELECT 
		branch,
        DAYNAME(STR_TO_DATE(date,'%d/%m/%Y')) AS day_name,
		COUNT(*) AS nu_of_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranking = 1;



-- Business Problem 4: Calculate the total quantity of items sold per payment method
SELECT 
	payment_method,
    SUM(quantity) AS total_items_sold
FROM walmart
GROUP BY payment_method;
   
   
    
-- Business Problem 5: Determine the average, minimum, and maximum rating of categories for each city
SELECT 
	city,
    category, 
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category
ORDER BY city, category;



-- Business Problem 6: Calculate the total profit for each category
SELECT
	category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
    
    
    
-- Business Problem 7: Determine the most common payment method for each branch
WITH cte AS 
(
	SELECT
		branch,
		payment_method,
		COUNT(*) AS nu_of_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM walmart
    GROUP BY branch, payment_method
) 
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE ranking =1;



-- Business Problem 8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
	branch,
    CASE 
		WHEN HOUR(TIME(time)) < 12 THEN "Morning"
		WHEN HOUR(TIME(time)) BETWEEN 12 and 17 THEN "Afternoon"
		ELSE "Evening"
    END AS shift,
    COUNT(*) AS nu_of_invoices
FROM walmart 
GROUP BY branch, shift
ORDER BY branch, nu_of_invoices DESC;



-- Business Problem 9: Identify the 5 branches with the highest revenue decrease ratio
-- from last year to current year (e.g., 2022 to 2023)
WITH r_2022 AS
(
	SELECT
		branch,
        SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
r_2023 AS
(
	SELECT
		branch,
        SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT
	r_2022.branch,
    r_2022.revenue,
    r_2023.revenue,
    ((r_2022.revenue - r_2023.revenue) / r_2022.revenue * 100) AS revenue_decline_ratio
FROM r_2022 
JOIN r_2023
ON r_2022.branch = r_2023.branch
WHERE r_2023.revenue < r_2022.revenue
ORDER BY revenue_decline_ratio DESC
LIMIT 5;

