create database sql_project;

create table retail_sales(
transactions_id int primary key,
sale_date date,
sale_time time,
customer_id int,
gender	varchar(50),
age	int,
category varchar(50),
quantiy	int,
price_per_unit	float,
cogs float,
total_sale float
);

select count(*) from retail_sales;

select * from retail_sales 
where transactions_id is null
or
sale_time is null
or
customer_id is null
or
gender is null
or
age is null
or
category is null
or
quantiy is null
or
price_per_unit is null
or
cogs is null
or
total_sale is null;

--- How many sales we have?

select count(*) as total_sales from retail_sales;

--- how many unique customer we have?

select count(distinct customer_id) as total_customer from retail_sales;

--- All category name

select distinct category from retail_sales;

--- Data analysis and Business key problem and answer

#Write a SQL query to retrieve all columns for sales made on '2022-11-05

select * from retail_sales
where sale_date = '2022-11-05';

#Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:

SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantiy >= 4
  AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11';
  
  #Write a SQL query to calculate the total sales (total_sale) for each category.:

  select category,
  sum(total_sale) as net_sales,
  count(*) as total_orders
  from retail_sales
  group by category;
  
  #Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:

select avg(age) as avg_age
 from retail_sales
where category = 'Beauty';

#Write a SQL query to find all transactions where the total_sale is greater than 1000.:

select * from retail_sales
where total_sale >1000;

#Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:

select category, gender,
count(*) as total_trans
from retail_sales
group by gender, category
order by 1;

# Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select * from
(select year(sale_date) as year,
month(sale_date) as month,
round(avg(total_sale),2) as avg_sales,
rank() over(partition by year(sale_date) order by month(sale_date)asc) as rnk
from retail_sales
group by 1, 2) as a
where rnk = 1;

#Write a SQL query to find the top 5 customers based on the highest total sales 

select customer_id, sum(total_sale) as sales
 from retail_sales
 group by customer_id
 order by sales desc limit 5;

#Write a SQL query to find the number of unique customers who purchased items from each category.

select category,
count(distinct customer_id ) as count_uniq_cust
from retail_sales
group by category;

#Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
with hourly_sale
as
(
select *,
   case
       when hour(sale_time) <12 then 'morning'
              when hour(sale_time) between 12 and 17 then 'afternoon'
              else 'evening'
              end as shift
 from retail_sales
 )
 select shift,
 count(*) as total_orders
 from hourly_sale
 group by shift;
 
 #End of project
 







 









