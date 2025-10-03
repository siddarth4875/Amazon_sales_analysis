use  amazon_sales;
create  database amazon_sales;
create table amazon_sales(
Invoice_ID	varchar (50) primary key not null,
Branch	enum('A','B','C') not null,
City	varchar(50) not null,
Customer_type	varchar(50) not null,
Gender	varchar(50) not null,
Product_line	varchar(200) not null,
Unit_price	decimal not null,
Quantity	int not null,
Tax_5	    decimal not null,
Total	  decimal not null,
Date	date,
Time	time,
Payment	  varchar(50) not null,
cogs	decimal not null,
gross_margin_percentage	   decimal not null,
gross_income	decimal not null,
Rating     decimal not null
);
-- Add a new column named timeofday
alter table amazon_sales
add column timeofday varchar(30);
Update amazon_sales
set timeofday = case 
   when hour(time)>=0 and hour(time) <12 then 'Morning'
   when hour(time)>=12 and hour(time) <17 then 'Afternoon'
   else 'Evening'
end
WHERE Invoice_ID IS NOT NULL;
--  Add a new column named dayname 
alter table amazon_sales
add column dayname varchar (5);
update amazon_sales
set dayname = date_format(date,'%a');
-- Add a new column named monthname 
alter table amazon_sales
add column monthname varchar(5);
update amazon_sales
set monthname = date_format(date,'%b');
SET SQL_SAFE_UPDATES = 1;
-- Exploratory Data analysis
-- 1.What is the count of distinct cities in the dataset?
select count(distinct city) as distnct_city_count
from amazon_sales;
-- For each branch, what is the corresponding city?
select branch , city
from amazon_sales
group by branch ,city;
-- What is the count of distinct product lines in the dataset?
select count(distinct Product_line) as productline_count
from amazon_sales;
-- Which payment method occurs most frequently?
select payment , count(*) as payment_method_count
from amazon_sales
group by payment
order by  count(*) desc;
-- Which product line has the highest sales?
select product_line, sum(total) as prodctline_sold
from amazon_sales
group by product_line
order by sum(total) desc
limit 1;
-- How much revenue is generated each month?
select monthname , sum(total) as revenue
from amazon_sales
group by monthname
order by  sum(total) desc;
-- In which month did the cost of goods sold reach its peak?
select monthname , sum(cogs) as total_cogs
from amazon_sales
group by monthname
order by sum(cogs) desc;
-- Which product line generated the highest revenue?
select product_line , sum(total) as revenue
from amazon_sales
group by product_line
order by sum(total) desc;
-- In which city was the highest revenue recorded?
select city , sum(Total) as revenue
from amazon_sales
group by city
order by sum(Total) desc;
-- Which product line incurred the highest Value Added Tax?
select product_line, sum(Tax_5) as VAT
from amazon_sales
group by product_line
order by sum(Tax_5) desc
limit 1;
-- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
with cte as (
select product_line, sum(Total) as total
from amazon_sales
group by Product_line),
avg_sale as (
select avg(total) as avg_total
from cte)
select cte.product_line , cte.total,avg_sale.avg_total,
case 
   when avg_sale.avg_total< cte.total  then 'Good'
   else 'Bad' 
   end as category
from cte,avg_sale ;
-- Identify the branch that exceeded the average number of products sold.
with cte as (
select branch , sum(Quantity) as total_quantity
from amazon_sales
group by branch),
avg_quantity as (
select avg(total_quantity) as avg_quantity
from cte)
select cte.branch , cte.total_quantity
from cte,avg_quantity
where avg_quantity.avg_quantity< cte.total_quantity;
-- Which product line is most frequently associated with each gender?
WITH ranked_product_lines AS (
    SELECT 
        gender,
        product_line,
        COUNT(*) AS product_count,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rn
    FROM amazon_sales
    GROUP BY gender, product_line
)
SELECT gender, product_line, product_count
FROM ranked_product_lines
WHERE rn = 1;
-- Calculate the average rating for each product line.
select product_line, avg(rating) as avg_rating
from amazon_sales
group by product_line
order by avg(rating) desc;
-- Count the sales occurrences for each time of day on every weekday.
select dayname, 
timeofday,count(*) as sales_count
from amazon_sales
group by dayname, timeofday
order by dayname,timeofday;
-- Identify the customer type contributing the highest revenue.
select customer_type, 
sum(total) as revenue
from amazon_sales
group by Customer_type;
-- Determine the city with the highest VAT percentage.
with cte as(
select city, sum(Tax_5) as vat
from amazon_sales
group by City)
select city , vat
from cte
where vat = (select max(vat) from cte);
-- Identify the customer type with the highest VAT payments.
select customer_type , sum(tax_5) as vat
from amazon_sales
group by Customer_type
order by sum(tax_5) desc;
-- What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as customer_type_count
from amazon_sales;
-- What is the count of distinct payment methods in the dataset?
select count(distinct payment) as payment_method_count
from amazon_sales;
-- Which customer type occurs most frequently?
select customer_type, count(*) as order_count
from amazon_sales
group by customer_type
order by count(*) desc
limit 1;
-- Identify the customer type with the highest purchase frequency.
select customer_type, count(*) as purchase_frequency
from amazon_sales
group by customer_type
order by count(*) desc
limit 1;
-- Determine the predominant gender among customers.
select gender, count(*) as order_count
from amazon_sales
group by Gender
order by count(*) desc
limit 1;
-- Examine the distribution of genders within each branch.
select branch, Gender, 
count(*) as gender_distribution
from amazon_sales
group by branch, Gender
order by branch, Gender;
-- Identify the time of day when customers provide the most ratings.
select timeofday, count(Rating) as rating_count
from amazon_sales
group by timeofday
order by count(Rating) desc;
-- Determine the time of day with the highest customer ratings for each branch.
with cte as
(select branch,timeofday, count(Rating) as rating_count,
row_number()over(partition by Branch order by count(Rating) desc) as rn
from amazon_sales
group by branch,timeofday)
select branch,timeofday,rating_count
from cte
where rn=1;
-- Identify the day of the week with the highest average ratings.
select dayname, avg(rating) as avg_rating
from amazon_sales
group by dayname
order by avg(rating) desc;
-- Determine the day of the week with the highest average ratings for each branch.
with cte as (
select branch,dayname, avg(rating) as avg_rating,
row_number()over(partition by Branch order by avg(rating) desc) as rn
from amazon_sales
group by branch,dayname)
select branch,dayname,avg_rating
from cte
where rn=1;











