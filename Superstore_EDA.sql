use black_friday;

## checking the table content and data type

select * from sample_superstore;
describe sample_superstore;

## Some data types need to be converted.
## But first let`s create a copy of the table, just in case
drop table if exists superstore;
create table superstore
as select * from sample_superstore;

## now let`s do the data type` conversion
Alter table superstore
modify Order_ID varchar(30) Not null,
modify Customer_ID varchar(30) not null,
modify Customer_Name varchar(100),
modify Product_ID varchar(30) not null,
modify Sales decimal(8,2),
modify Profit decimal(8,2);

## check the output
select * from superstore;
describe superstore;

## convert order_date, ship_date from text to date type
UPDATE superstore
SET Order_date = STR_TO_DATE(Order_date, '%d-%m-%Y');

ALTER TABLE superstore
MODIFY COLUMN Order_date date;

UPDATE superstore
SET Ship_date = STR_TO_DATE(Ship_date, '%d-%m-%Y');

ALTER TABLE superstore
MODIFY COLUMN Ship_date date;

## let`s check what we got
select Order_date, Ship_date from superstore; ##looks good

## Now let`s do some EDA
## 1. I want to know how many distinct customers in the dataset
## by region, state
select count(distinct Customer_ID) from superstore;  ## 648
select count(distinct Customer_ID), state, region from sample_superstore
group by region with rollup; ## looks like some customers have made orders from different states. 

## 2. Let`s focus on sales
## Check sales and profit performance throughout the years
select
extract(year from Order_date) as Order_Date,
sum(Sales) as Total_Sales,
sum(Profit) as Total_profit
from superstore
group by 1
order by 1 desc; ## I can see, that the overall strategy was succesfull, even with the sales going down in 2015, total profit went up significantly.

## let`s have a closer look what had been happening with sales and profit quaterly during these years
select year(order_date), quarter(order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2017'
group by 2
union all
select year(order_date), quarter(order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2016'
group by 2
union all 
select year(order_date), quarter(order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2015'
group by 2
union all
select year(order_date), quarter(order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2014'
group by 2
order by 1 desc,2 asc;
## I definitely need a graph to see the full picture 
## but 4th quarter is comonly succesfull in sales for all years

## aslo let`s write a query for monthly sales and profit and evaluate the output in visualization
select year(order_date), month(Order_date), monthname(Order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2017'
group by 2
union
select year(order_date), month(Order_date), monthname(Order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2016'
group by 2
union
select year(order_date), month(Order_date), monthname(Order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2015'
group by 2
union
select year(order_date), month(Order_date), monthname(Order_date), sum(Sales) as Total_Sales, sum(Profit) as Total_profit
from superstore
where year(order_date)='2014'
group by 2
order by 1 desc, 2 asc;

## sales and profit thoughout the regions, states and cities.
## Let`s check the highest sales geographically

## by region
select region, sum(Sales), sum(Profit)
from superstore
group by 1
order by 2 desc;
## West region has the highest sales in total.
## Was it like that during all 4 years?

select year(order_date), region, sum(sales), sum(Profit)
from superstore
where year(order_date) = '2017'
group by region
union
select year(order_date), region, sum(sales), sum(Profit) 
from superstore
where year(order_date) = '2016'
group by region
union
select year(order_date), region, sum(sales), sum(Profit)
from superstore
where year(order_date) = '2015'
group by region
union
select year(order_date), region, sum(sales), sum(Profit)
from superstore
where year(order_date) = '2014'
group by region
order by 1 desc, 3 desc; ## looks like East and West are main competitors, what I observed in the previous query as well

## now let`s have a look at sales/profit by state and city
select state, sum(Sales), sum(Profit)
from superstore
group by 1
order by 2 desc;
/* there are top 5 states by sales, but if I check the profit, then I get the different picture
California
New York
Texas
Florida
Pennsylvania*/

select state, sum(Sales), sum(Profit)
from superstore
group by 1
order by 3 desc;
/* so Top 2 are still the same players, but other 3 are different. 
New York
California
Washington
Georgia
Michigan
I can assume that sales/discount/profit strategy is different from one state to another,
which gives them the different outcome */

## let`s check the best city in sales/profit
select country, state, city, sum(quantity) as Total_sold, sum(sales) as total_sales, sum(profit) as total_profit
from superstore
group by city
order by 6 desc;
## New York City, Seattle, Los Angeles - top 3 profitable cities.
## New-York is all-time leader in sales/profit/ammount of goods sold

## let`s check if the profit was affected by wrong discount strategy
select country, state, city, sum(quantity) as Total_sold, sum(sales) as total_sales, sum(profit) as total_profit,
avg(discount) as avg_discount
from superstore
group by city
having total_sales >=10000
order by 7;
## I can see that discounts > 30%  caused profit loss

## now let`s check which segment, category and item generated the most profit
with Item as
(select segment, category, sub_category, product_name, sum(quantity) as total_sold, sum(profit) as total_profit
from superstore
group by 1,2,3,4
order by 6 desc),
Item_Profit as
(select*,
case
when total_profit/total_sold >500 then 'Profit Maker'
when total_profit/total_sold between 0 and 500 then 'Volume Maker'
else 'Not profitable'
end as Item_Status
from Item)
select * from Item_Profit;
## 3 items in Technology category are real Profit makers

## let`s check the most popular delivery type and how it reflects on profit and sales
select ship_mode, count(ship_mode) as delivered_total, 
round(avg(datediff(ship_date, order_date)),2) as delivery_lag, 
sum(sales) as total_sales, sum(profit) as total_profit
from superstore
group by 1
order by delivery_lag;
## standard class is the most popular option chosen by a cutomer. The average lag time before shipping is 5 days.
## There is a possibility that improving the delivery process the store could positively affect on profit, 
## as the standard delivery is the most profitable segment of customers