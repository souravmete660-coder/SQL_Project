create database swiggy_database;

create table swiggy_data(
State varchar(25),	
City varchar(25),
Order_Date date,
Restaurant_Name	varchar(65),
Location varchar(50),
Category varchar(50),
Dish_Name varchar(65),
Price_INR float,
Rating	float,
Rating_Count int
);

SET GLOBAL local_infile = 1;

load data local infile "C:/Users/dell/Downloads/Swiggy_Data..csv" into table swiggy_data
fields  terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

#Data validation and data cleaning
#null check

SELECT
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Order_date IS NULL THEN 1 ELSE 0 END) AS null_Order_date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_Restaurant_Name,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_Location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_Category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_Dish_name,
    SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price_INR,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_Rating,
    SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_Rating_count
FROM swiggy_data;  

#Blanke & empty string
select * from swiggy_data 
where state = '' or city = '' or order_date = '' or restaurant_name = ''
or location = '' or category = '' or dish_name = '' or price_inr = ''
or rating = '' or rating_count = '';

#Duplicate detection
select state, city, order_date, restaurant_name, location, 
category, dish_name, price_inr, rating, rating_count, count(*)
from swiggy_data
group by 
state, city, order_date, restaurant_name, location, 
category, dish_name, price_inr, rating, rating_count
having count(*) >1;

#Creating schema
#Dimension tables
#date table

CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    day INT,
    week INT
);

#Dim_location
create table dim_location(
location_id int auto_increment primary key,
state varchar(100),
city varchar(100),
location varchar(100)
);

#dim_restrunt
create table dim_restaurant(
restaurant_id int auto_increment primary key,
restaurant_name varchar(200)
);

#dim_catergory
create table dim_category(
category_id int auto_increment primary key,
category varchar(200)
);

#dim_dish
create table dim_dish(
dish_id int auto_increment primary key,
dish_name varchar(200)
);

#fact_table
CREATE TABLE fact_swiggy_orders (

    order_id INT AUTO_INCREMENT PRIMARY KEY,

    date_id INT,
    price_inr DECIMAL(10,2),
    rating DECIMAL(4,2),
    rating_count INT,

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id) 
        REFERENCES dim_date(date_id),

    FOREIGN KEY (location_id) 
        REFERENCES dim_location(location_id),

    FOREIGN KEY (restaurant_id) 
        REFERENCES dim_restaurant(restaurant_id),

    FOREIGN KEY (category_id) 
        REFERENCES dim_category(category_id),

    FOREIGN KEY (dish_id) 
        REFERENCES dim_dish(dish_id)

);

#insert data into table
# dim date\
INSERT INTO dim_date (
    full_date,
    year,
    month,
    month_name,
    quarter,
    day,
    week
)

SELECT DISTINCT
    order_date,
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    QUARTER(order_date),
    DAY(order_date),
    WEEK(order_date)

FROM swiggy_data
WHERE order_date IS NOT NULL;

#dim_location
insert into dim_location (state, city, location)
select distinct 
         state,
         city,
         location
from swiggy_data;   

#dim_restaurant
insert into dim_restaurant (restaurant_name) 
select distinct restaurant_name 
from swiggy_data;
     
#dim_category
insert into dim_category(category)
select distinct category
from swiggy_data;    

#dim_dish
insert into dim_dish(dish_name)
select distinct dish_name
from swiggy_data;

SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;

SET GLOBAL max_allowed_packet = 1073741824;

#Fact_table
insert into fact_swiggy_orders(
date_id,
price_inr,
rating,
rating_count,
location_id,
restaurant_id,
category_id,
dish_id
)
select
    dd.date_id,
    s.Price_INR,
    s.rating,
    s.rating_count,
    
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
 from swiggy_data s
 
 join dim_date dd
    on dd.full_date = s.order_date
    
join dim_location dl
    on dl.state = s.state 
	and dl.city = s.city
	and dl.location = s.location
    
join dim_restaurant dr
   on dr.restaurant_name = dr.restaurant_name    
    
join dim_category dc
on dc.category = s.Category

join dim_dish dsh
on dsh.dish_name = s.dish_name
limit 10000;

select * from fact_swiggy_orders f 
join dim_date d on f.date_id = d.date_id
join dim_location l on f.location_id = l.location_id
join dim_restaurant r on f.restaurant_id = r.restaurant_id
join dim_category c on f.category_id = c.category_id
join dim_dish di on f.dish_id = di.dish_id;

#KPI's
#Total_orders
select count(*) as total_orders
from fact_swiggy_orders;

#Total_revenue(inr million)
SELECT 
    CONCAT(
        ROUND(SUM(CAST(price_inr AS DECIMAL(10,2))) / 1000000, 2),
        ' INR Million'
    ) AS total_revenue
FROM fact_swiggy_orders;

#Avg dish price
SELECT
    CONCAT(
        ROUND(AVG(CAST(price_inr AS DECIMAL(10,2))), 2),
        ' INR'
    ) AS avg_price
FROM fact_swiggy_orders;

#Avg_rating
select avg(rating) as avg_rating
from fact_swiggy_orders;

#Deep-Drive business analysis
#monthly order trands
select year, month, month_name, 
count(*) as total_orders
from fact_swiggy_orders f
join dim_date d
on f.date_id = d.date_id
group by year, month, month_name
order by total_orders desc;

#Quarterly trands
select year, quarter,
count(*) as total_order
from fact_swiggy_orders f
join dim_date d
on f.date_id = d.date_id
group by year, quarter
order by total_order desc;

#yearly trands
select year, count(*) as total_year
from fact_swiggy_orders f
join dim_date d
on f.date_id = d.date_id
group by year 
order by total_year desc;

#order by day of week (mon-sun)
SELECT
     DAYNAME(full_date) AS day_name,
     count(*) as total_orders
FROM dim_date
group by day_name
order by total_orders desc;

#location based analysis
#top 10 city by order volume
select city,
count(*) as total_orders
from fact_swiggy_orders 
join dim_location 
on fact_swiggy_orders.location_id = dim_location.location_id
group by city
order by total_orders desc limit 10;

#Revenue contribution by state
select state,
sum(price_inr) as total_revenue
from fact_swiggy_orders f
join dim_location l
on f.location_id = l.location_id
group by state
order by total_revenue desc;

#food performence
#top 10 restaurant by orders
select restaurant_name, count(*) as total_orders
from fact_swiggy_orders s
join dim_restaurant r
on r.restaurant_id = s.restaurant_id
group by restaurant_name
order by total_orders desc limit 10;

#Top category by order values
select category, count(*) as total_orders
from fact_swiggy_orders s
join dim_category r
on r.category_id = s.category_id
group by category
order by total_orders desc;

#most order_dishes
select dish_name, count(*) as total_orders
from fact_swiggy_orders f
join dim_dish d
on f.dish_id = d.dish_id
group by dish_name
order by total_orders desc;

#Cuisine performence (orders + avg ratings)
select 
 c.category,
 count(*) as total_orders,
 avg(rating) as avg_rating
 from fact_swiggy_orders f 
 join dim_category c 
 group by category
 order by total_orders, avg_rating;
 
 # total_orders by price range
 select
      case when price_inr <100 then 'Under 100'
		   when price_inr between 100 and 199 then '100 - 199'
           when price_inr between 200 and 299 then '200 - 299'
           when price_inr between 300 and 399 then '300 - 399'
           when price_inr between 400 and 499 then '400 - 499'
           else '500+'
       end as price_range,
       count(*) as total_orders
   from fact_swiggy_orders    
   group by price_range
     order by total_orders desc;
     
#rating count distribution
select rating, count(*) as total_rating
from fact_swiggy_orders
group by rating
order by total_rating desc;     
     
     
     
     
       
       
           
           
 
 






    
