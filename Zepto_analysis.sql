create database zepto_sql_project;

create table zepto (
Category varchar(120),
name varchar(25),
mrp	numeric(8,2),
discountpercent numeric(5,2),
availableQuantity int,
discountedSellingPrice numeric (8,2),
weightInGms int,
outOfStock boolean,
quantity int
);

SET GLOBAL local_infile = 1;

load data local infile "C:/Users/dell/Downloads/zepto_v1.csv" into table zepto
fields  terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines;

#Data exploration

#Count of rows
select count(*) from zepto;

#sample data
select * from zepto
limit 10;

#null count
select * from zepto
where Category is null
or
name is null
or
mrp is null
or
discountpercent is null
or
availableQuantity is null
or
discountedSellingPrice is null
or
weightInGms is null
or
outOfStock is null
or
quantity is null;

#different product category
select distinct category
from zepto
order by category;

#product in stock vs out of stock. 
select outOfStock, count(*)
from zepto
group by outOfStock;

# product name present in multiple time
select name, count(*)
from zepto
group by name
having count(*)>1
order by count(*) desc;

#Data cleaning

#product with price = 0
select * from zepto
where mrp = 0 or discountedSellingPrice = 0;

SET SQL_SAFE_UPDATES = 0;

delete from zepto
where mrp = 0;

#convart paisa into ruppies
update zepto
set mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

select mrp, discountedsellingPrice from zepto;

#-- Q1. Find the top 10 best-value products based on the discount percentage.
select distinct name, mrp, discountpercent from zepto
order by discountpercent desc 
limit 10;

#--Q2.What are the Products with High MRP but Out of Stock
select category, name, mrp from zepto
where outOfStock = 'true'
order by mrp desc;

#anothor method
select distinct name, mrp
from zepto
where outOfStock = 'true' and mrp >300
order by mrp desc;

#--Q3.Calculate Estimated Revenue for each category
select Category, sum(discountedSellingPrice * quantity) as est_revenue
from zepto
group by Category
order by est_revenue desc;

#-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select distinct name, mrp, discountpercent
from zepto
where mrp >500 and discountpercent <10
order by mrp desc, discountpercent desc;

#-- Q5. Identify the top 5 categories offering the highest average discount percentage.
select category, round(avg(discountpercent),2) as avg_discount
from zepto
group by Category
order by avg_discount desc
limit 5;

#-- Q6. Find the price per gram for products above 100g and sort by best value.
select distinct name, weightingms, discountedsellingprice,
round(discountedsellingprice/weightingms,2) as price_per_gram
from zepto
where weightInGms >100
order by price_per_gram;

#--Q7.Group the products into categories like Low, Medium, Bulk.
select distinct name, weightingms,
case when weightingms <1000 then 'low'
     when weightingms <5000 then 'medium'
     else 'bulk'
     end as 'weight_category'
     from zepto;
     
#--Q8.What is the Total Inventory Weight Per Category 
select category, sum(weightInGms *availableQuantity) as total_weight
from zepto
group by category
order by total_weight;