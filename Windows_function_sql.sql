select category, name, count(category) 
over (partition by category) 
from pizza_types;

#Running Total Sales
WITH a AS (
    SELECT 
        orders.order_date,
        ROUND(SUM(order_details.quantity * pizzas.price), 2) AS sales
    FROM orders 
    JOIN order_details USING(order_id)
    JOIN pizzas USING(pizza_id)
    GROUP BY orders.order_date
)

SELECT 
    *,
    SUM(sales) OVER (ORDER BY order_date) AS running_total,
    SUM(sales) OVER (PARTITION BY MONTH(order_date) ORDER BY order_date) AS MTD
FROM a;

--- rank(), dense_rank, row_number

select pizza_types.category,
pizza_types.name,
pizzas.size,
pizzas.price,
rank() over(order by pizzas.price desc) rnk,
dense_rank() over(order by pizzas.price desc) d_rnk,
row_number() over(order by pizzas.price desc) rn_no
from pizzas 
join pizza_types using(pizza_type_id);

#fetch top 3 pizzas by each category

select * from(select pizza_types.category,
pizza_types.name,
pizzas.size,
pizzas.price,
dense_rank() over (partition by pizza_types.category order by pizzas.price desc) rnk
from pizzas 
join pizza_types using (pizza_type_id)) a
where rnk <=3;

#find median by row_number
with a as (select price,
row_number() over (order by price) pos,
count(*) over() n
from pizzas)

select case
when n % 2 = 0 then (select avg(price) from a where pos in ((n/2), (n/2)+1))
else(select price from a where pos =(n+1)/2 )
end as median from a limit 1;

#MOM Growth
#(CM-PM/PM)

with a as (SELECT month(orders.order_date) months,
	ROUND(SUM(order_details.quantity * pizzas.price), 2) AS sales
    FROM orders 
    JOIN order_details USING(order_id)
    JOIN pizzas USING(pizza_id)
    GROUP BY orders.order_date)
    
    select months,concat(coalesce(round(((sales-prev_month)/prev_month)*100,2),0),"%") as MOM_growth from
    (select *, lag(sales, 1) over (order by months) prev_month from a) b;
    

select pizza_types.category,
pizza_types.name,
pizzas.size,
pizzas.price,
first_value(pizza_types.name) over(partition by pizza_types.category order by price desc)
from pizzas 
join pizza_types using(pizza_type_id);

#moving 
with a as (SELECT month(orders.order_date) months,
	ROUND(SUM(order_details.quantity * pizzas.price), 2) AS sales
    FROM orders 
    JOIN order_details USING(order_id)
    JOIN pizzas USING(pizza_id)
    GROUP BY orders.order_date)
	
    select *, 
    round(avg(sales) over(rows between 2 preceding and current row),2) from a;
    