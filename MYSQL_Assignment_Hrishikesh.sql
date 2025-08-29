-- MySql Assignement (Hrishikesh Manohar Dhondge)

use classicmodels;

-- Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- a) Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)
select employeenumber, firstname, lastname
from employees
where jobtitle='sales rep' and reportsto=1102;

-- b) Show the unique productline values containing the word cars at the end from the products table.
select distinct productline
from products
where productline like '%cars';


-- Q2 CASE STATEMENTS for Segmentation
-- Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
--  "North America" for customers from USA or Canada
--  "Europe" for customers from UK, France, or Germany
--  "Other" for all remaining countries
-- Select the customerNumber, customerName, and the assigned region as "CustomerSegment".
select customernumber, customername,
case 
when country in ('USA','canada') then "North America"
when country in ('UK','france','germany') then "Europe"
else "Other" 
end as CustomerSegment
from customers;


-- Q3. Group By with Aggregation functions and Having clause, Date and Time functions
-- a) Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
select productcode, sum(quantityordered) as total_ordered
from orderdetails
group by productcode
order by total_ordered desc
limit 10;

-- b) Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order.  (Refer Payments table). 
select * from payments;
select monthname(paymentdate) as payment_month,
count(paymentdate) as num_payments
from payments
group by payment_month
having num_payments>20;


-- Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- Create a new database named and Customers_Orders and add the following tables as per the description
-- a) Create a table named Customers to store customer information. Include the following columns:
-- customer_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
-- first_name: This should be a VARCHAR(50) to store the customer's first name.
-- last_name: This should be a VARCHAR(50) to store the customer's last name.
-- email: This should be a VARCHAR(255) set as UNIQUE to ensure no duplicate email addresses exist.
-- phone_number: This can be a VARCHAR(20) to allow for different phone number formats.
-- Add a NOT NULL constraint to the first_name and last_name columns to ensure they always have a value.
 create database Customers_Orders;
use Customers_Orders;
create table Customers (
customer_id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(255) unique,
phone_number varchar(20)
);

-- b) Create a table named Orders to store information about customer orders. Include the following columns:
-- order_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
-- customer_id: This should be an integer referencing the customer_id in the Customers table  (FOREIGN KEY).
-- order_date: This should be a DATE data type to store the order date.
-- total_amount: This should be a DECIMAL(10,2) to store the total order amount.  	
-- Constraints:
-- a)	Set a FOREIGN KEY constraint on customer_id to reference the Customers table.
-- b)	Add a CHECK constraint to ensure the total_amount is always a positive value.
create table Orders (
order_id int primary key auto_increment,
customer_id int,
order_date date,
total_amount decimal (10,2)
);
Alter table Orders
Add Constraint fk_OC
Foreign Key (customer_id)
references Customers(customer_id),
Add Constraint check_num
check(total_amount>0);
desc orders;


-- Q5. JOINS
-- List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
select country, count(orderDate) as order_count
from customers inner join Orders
on customers.customernumber=orders.customernumber
group by country
order by order_count desc
limit 5;


-- Q6. SELF JOIN
-- Create a table project with below fields.
-- ●	EmployeeID : integer set as the PRIMARY KEY and AUTO_INCREMENT.
-- ●	FullName: varchar(50) with no null values
-- ●	Gender : Values should be only ‘Male’  or ‘Female’
-- ●	ManagerID: integer 
-- Find out the names of employees and their related managers.
create table project
(
EmployeeID int primary key auto_increment,
FullName varchar(50) not null,
Gender varchar(10) check (Gender in ('Male','Female')),
ManagerID int
);
insert into project (FullName,Gender,ManagerID) values 
('Pranaya','Male',3),
('Priyanka','Female',1),
('Preety','Female',null),
('Anurag','Male',1),
('Sambit','Male',1),
('Rajesh','Male',3),
('Hina','Female',3);

Select M1.FullName as 'Manager Name', E1.FullName as 'Emp Name'
from project M1 join project E1
on M1.employeeid=E1.managerid
order by M1.Fullname asc;


-- Q7. DDL Commands: Create, Alter, Rename
-- Create table facility. Add the below fields into it.
--●	Facility_ID
--●	Name
--●	State
--●	Country
--i) Alter the table by adding the primary key and auto increment to Facility_ID column.
--ii) Add a new column city after name with data type as varchar which should not accept any null values.
Create table facility
(
Facility_ID int,
Name varchar(100),
State varchar(100),
Country varchar(100)
);
desc facility;
alter table facility
modify column Facility_ID int Primary Key auto_increment;
alter table facility
add column City varchar(100) not null after Name;


-- Q8. Views in SQL
-- Create a view named product_category_sales that provides insights into sales performance by product category. This view should include the following information:
-- productLine: The category name of the product (from the ProductLines table).
-- total_sales: The total revenue generated by products within that category (calculated by summing the orderDetails.quantity * orderDetails.priceEach for each product in the category).
-- number_of_orders: The total number of orders containing products from that category.
-- (Hint: Tables to be used: Products, orders, orderdetails and productlines)
create view product_category_sales as
select p1.productline, 
sum(od.quantityOrdered*od.priceEach) as total_sales, 
count(distinct o.orderNumber) as number_of_orders
from productlines p1 join products p join orderdetails od join orders o 
on p1.productline=p.productline and p.productcode=od.productcode
and od.ordernumber=o.ordernumber
group by p.productline;

select * from product_category_sales;


-- Q9. Stored Procedures in SQL with parameters
-- Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)
-- Tables: Customers, Payments

/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_country_payments`(in input_Y int, in input_C varchar(50))
BEGIN
select year(p.paymentDate) as Year, c.Country, concat(round(sum(p.amount)/1000),'K') as 'Total Amount'
from customers c join payments p
on c.customerNumber=p.customerNumber
where c.country=input_C and year(p.paymentDate)=input_Y
group by Year,c.Country;
END
*/


-- Q10. Window functions - Rank, dense_rank, lead and lag
-- a) Using customers and orders tables, rank the customers based on their order frequency
select c.customerName, count(o.orderNumber) as Order_count,
rank() over (order by count(o.orderNumber) desc) as order_frequency_rnk
from customers c join orders o
on c.customerNumber=o.customerNumber
group by c.customername
order by Order_count desc;

-- b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
-- Table: Orders
WITH OrderCounts AS (
    SELECT 
        YEAR(orderDate) AS Year, 
        MONTHNAME(orderDate) AS Month,
        COUNT(orderNumber) AS Total_Orders
    FROM Orders
    GROUP BY Year, Month
),
YoY AS (
    SELECT 
        Year, 
        Month, 
        Total_Orders, 
        LAG(Total_Orders) OVER (ORDER BY Year) AS Prev_Year_Orders,
        CASE 
            WHEN LAG(Total_Orders) OVER (ORDER BY Year) IS NOT NULL 
            THEN CONCAT(ROUND(((Total_Orders - LAG(Total_Orders) OVER (ORDER BY Year)) 
            / LAG(Total_Orders) OVER (ORDER BY Year)) * 100, 0), '%') 
            ELSE NULL
        END AS YoY_Change
    FROM OrderCounts
)
SELECT Year, Month, Total_Orders as 'Total Orders', YoY_Change as '% YoY Change'
FROM YoY
ORDER BY Year, 
    FIELD(Month, 'January', 'February', 'March', 'April', 'May', 'June', 
                  'July', 'August', 'September', 'October', 'November', 'December');
                  

-- Q11. Subqueries and their applications
-- Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.
select p.productLine, count(*) as Total
from products p join productlines pl
on p.productline=pl.productline
where p.buyPrice > (select avg(buyPrice) from products)
group by p.productLine;


-- Q12. ERROR HANDLING in SQL
-- Create the table Emp_EH. Below are its fields.
--●	EmpID (Primary Key)
--●	EmpName
--●	EmailAddress
--Create a procedure to accept the values for the columns in Emp_EH. Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.
create table Emp_EH (
EmpID int primary key,
EmpName varchar(100),
EmpAddress varchar(300)
);

/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `Insert_Emp`(in id int, in ename varchar(100),  in email varchar(250))
BEGIN
declare continue handler for sqlexception
Begin
select 'Error occured' as Msg;
end;
insert into Emp_EH (EmpID, EmpName, EmailAddress)
values (id, ename, email);
END
*/

call Insert_Emp(1,'Raju','raju@gmail.com');
call Insert_Emp(1,'Sham','sham@gmail.com');


-- Q13. TRIGGERS
-- Create the table Emp_BIT. Add below fields in it.
--●	Name
--●	Occupation
--●	Working_date
--●	Working_hours

--Insert the data as shown in below query.
--INSERT INTO Emp_BIT VALUES
--('Robin', 'Scientist', '2020-10-04', 12),  
--('Warner', 'Engineer', '2020-10-04', 10),  
--('Peter', 'Actor', '2020-10-04', 13),  
--('Marco', 'Doctor', '2020-10-04', 14),  
--('Brayden', 'Teacher', '2020-10-04', 12),  
--('Antonio', 'Business', '2020-10-04', 11);  
 
--Create before insert trigger to make sure any new value of Working_hours, if it is negative, then it should be inserted as positive.

create table Emp_BIT (
Name varchar(10),
Occupation varchar(20),
Working_date date,
Working_hours int
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

/*
CREATE DEFINER=`root`@`localhost` TRIGGER `emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW BEGIN
if new.Working_hours<0 then
set new.Working_hours=-new.Working_hours;
end if;
END
*/

select * from emp_bit;
insert into emp_bit values
('Raju','Actor','2025-10-01',-15);  


