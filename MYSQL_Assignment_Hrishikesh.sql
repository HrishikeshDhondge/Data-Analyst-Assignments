-- MySql Assignement (Hrishikesh Manohar Dhondge)

use classicmodels;

-- Q1. 
-- a)
select employeenumber, firstname, lastname
from employees
where jobtitle='sales rep' and reportsto=1102;

-- b) 
select distinct productline
from products
where productline like '%cars';


-- Q2
-- a)
select customernumber, customername,
case 
when country in ('USA','canada') then "North America"
when country in ('UK','france','germany') then "Europe"
else "Other" 
end as CustomerSegment
from customers;


-- Q3. 
-- a)
select productcode, sum(quantityordered) as total_ordered
from orderdetails
group by productcode
order by total_ordered desc
limit 10;

-- b)
select * from payments;
select monthname(paymentdate) as payment_month,
count(paymentdate) as num_payments
from payments
group by payment_month
having num_payments>20;


-- Q4.
-- a)
create database Customers_Orders;
use Customers_Orders;
create table Customers (
customer_id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(255) unique,
phone_number varchar(20)
);

-- b)
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


-- Q5.
-- a)
select country, count(orderDate) as order_count
from customers inner join Orders
on customers.customernumber=orders.customernumber
group by country
order by order_count desc
limit 5;


-- Q6.
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


-- Q7.
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


-- Q8.
create view product_category_sales as
select p1.productline, 
sum(od.quantityOrdered*od.priceEach) as total_sales, 
count(distinct o.orderNumber) as number_of_orders
from productlines p1 join products p join orderdetails od join orders o 
on p1.productline=p.productline and p.productcode=od.productcode
and od.ordernumber=o.ordernumber
group by p.productline;

select * from product_category_sales;


-- Q9.
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


-- Q10. 
-- a)
select c.customerName, count(o.orderNumber) as Order_count,
rank() over (order by count(o.orderNumber) desc) as order_frequency_rnk
from customers c join orders o
on c.customerNumber=o.customerNumber
group by c.customername
order by Order_count desc;

-- b)
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
                  

-- Q11.
select p.productLine, count(*) as Total
from products p join productlines pl
on p.productline=pl.productline
where p.buyPrice > (select avg(buyPrice) from products)
group by p.productLine;


-- Q12.
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


-- Q13.
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


