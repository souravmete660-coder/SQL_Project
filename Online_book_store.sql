create database online_book_store;

#Create table books
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

#Create table Customers
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

#Create table Customers
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

select * from books;

select * from customers;

select * from orders;

# 1.Retrieve all books in the 'Fiction' genre. 
select * from books
where genre = 'Fiction';

# 2.Find books published after the year 1950;
select * from books 
where published_year >1950;

#3. list all the customers from the canada
select * from customers
where Country = 'Canada';

# 4. Show orders placed in november 2023
select * from orders
where Order_Date between '2023-11-01' and '2023-11-30';

# 5. Retrieve total stock of books available. 
select sum(Stock) as Total_stock from books;

# 6. find the details of most expensive book.
select * from books
order by Price desc limit 1;

#7.show all customers who orderd more than 1 quantity of a book. 
select * from orders
where Quantity >1;

#8. Retrieve all orders where the total amount exceeds $20
select * from orders
where total_amount> 20;

#9. list all genres available in the book table. 
select distinct genre from books;

#10. find the book with lowest stocks. 
select * from books
order by stock asc limit 1;

#11. Calcutale total revenue generated from all orders. 
select sum(Total_amount) as Revenue
from orders;

#Advanced questions

#12. Retrieve the total number of book sold for each genre. 

select books.Genre, sum(orders.Quantity) as book_sold
from orders
join books
using(book_id)
group by Genre;

#13. Find the average price of books in 'fantacy' genre. 
select avg(price) from books
where Genre = 'Fantasy';

#14. list of customers who has placed at least 2 orders. 
select orders.Customer_ID, customers.name, count(Order_ID)
from orders
join customers
using(customer_id)
group by Customer_ID
having count(Order_ID)>2;

#15. find the most frequently order book. 
select orders.book_id, customers.Name, count(order_id) as order_count
from orders
join customers
using(customer_id)
group by orders.book_id, customers.Name
order by order_count desc limit 1;

#16. Show the top 3 most expensive book in fantacy genre. 
select * from books
where Genre = 'Fantacy'
order by Price desc limit 3;

#17. retrive total quantity of books sold by each genra. 
select books.Genre, sum(orders.Quantity) as total_quantity
from books 
join orders
using(book_id)
group by books.Genre;

# 18. list the cities where customer who spent over $30 are located. 
select distinct city 
from customers
join orders
using(customer_id)
where total_amount > 30;

#19. find the customer who spent the most on order.
select customer.customer_id, customer.name, sum(total_amount) as Total_spent
from customer 
join orders
using(customer_id)
group by customer.customer_id, customer.name
order by Total_Amount desc limit 1;













 








