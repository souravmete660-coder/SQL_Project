RENAME TABLE mytable TO walmart_sales;

select count(*) from walmart_sales;

select payment_method,
count(*) as count
from walmart_sales
group by payment_method
order by count;

select count(distinct Branch) from walmart_sales;

select max(quantity) from walmart_sales;

--- Business problem
# Q.1 find different payment method number of transation, number of quantity sold
select payment_method, count(*) as no_payments,
count(quantity) as Quantity_sold
from walmart_sales
group by payment_method;

# Q.2 Identityfy the highest-rated category in each brunch, display the branch, category, avg rating
select * from 
(select branch, 
category, 
avg(rating) as avg_rating,
rank() over(partition by branch order by avg_rating desc) as rnk
from walmart_sales
group by branch, category)
where rnk>1;

# Q.3 Identify the busiest day for each branch based on the number
SELECT *
FROM (
    SELECT 
        branch,
        DAYNAME(`date`) AS day_name,
        COUNT(*) AS no_transaction,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY COUNT(*) ASC
        ) AS rnk
    FROM walmart_sales
    GROUP BY branch, DAYNAME(`date`)
) AS ranked_data
WHERE rnk = 1;

# Q.4 Calculate the total quantity of items sold per payment method. list payment method and total quantity. 
select payment_method,
count(*) as item_sold
from walmart_sales
group by payment_method
order by item_sold desc;

# Q.5 Determine the average, minimum, maximum rating of category for each city
# list city, average, minimum, maximum rating 
select city,
category,
round(avg(rating),2) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart_sales
group by city, category;

# Q.6 calculate total profit for each category
select category,
round(sum(total),2) as revenue,
round(sum(total * profit_margin),2) as profit
from walmart_sales
group by category
order by profit desc;

# Q.7 determine the most common payment method for each branch.
# Display the branch and praferd paymemt method 
with cte as
(select branch, 
payment_method, 
count(*) as total_trans,
rank() over(partition by branch order by count(*) desc) as rnk
from walmart_sales
group by branch, payment_method)
select * from cte 
where rnk = 1;

# Q.8 Categarize sales into 3 groups morning, afternoon, evening
# find which of the sift and number of invoices
SELECT
    branch,
    CASE
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) < 12 THEN 'Morning'
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_transactions
FROM walmart_sales
GROUP BY branch, day_time
ORDER BY branch, total_transactions DESC;

# Q.9 Identify 5 branches with highest decrese ratio in 
# Revenue compare to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart_sales
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),

revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart_sales
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)

SELECT
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS current_year_revenue,

    ROUND(
        ((ls.revenue - cs.revenue) / ls.revenue) * 100,
        2
    ) AS rev_dec_ratio

FROM revenue_2022 ls
JOIN revenue_2023 cs
    ON ls.branch = cs.branch

WHERE ls.revenue > cs.revenue

ORDER BY rev_dec_ratio DESC

LIMIT 5;