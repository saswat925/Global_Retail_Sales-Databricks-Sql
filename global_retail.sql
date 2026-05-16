--Global Retail Sales ANALYSIS
use catalog waerehouse;
use schema retail;

--STAR SCHEMA DESIGN ANALYSIS

                  --dim_customers
                         --|
                         --|
--dim_products ---- fact_sales ---- dim_stores
                         --|
                         --|
              --dim_exchange_rates
                         --|
                         --|
                    --dim_date

--By schema design all tables, i will copy all the tables from raw table and then analysis

-------------------------------
-- FACT TABLE
-------------------------------

CREATE OR REPLACE TABLE fact_sales AS
SELECT
    Order_Number,
    Line_Item,
    Order_Date,
    Delivery_Date,
    Customer_Key,
    Store_Key,
    Product_Key,
    Quantity,
    Currency_Code
FROM sales;


-------------------------------
-- DIM_CUSTOMERS
-------------------------------

CREATE OR REPLACE TABLE dim_customers AS
SELECT
    Customer_Key,
    Gender,
    Name,
    City,
    `State Code` as state_code,
    State,
    `Zip Code` as zip_code,
    Country,
    Continent,
    Birthday
FROM customers;


-------------------------------
-- DIM_PRODUCTS
-------------------------------

CREATE OR REPLACE TABLE dim_products AS
SELECT
    Product_Key,
    Product_Name,
    Brand,
    Color,
   try_CAST(REGEXP_REPLACE(Unit_Cost_USD, '\\$', '') AS DOUBLE) AS Unit_Cost_USD,
  try_CAST(REGEXP_REPLACE(Unit_Price_USD, '\\$', '') AS DOUBLE) AS Unit_Price_USD,
    Sub_category_Key,
    Sub_category,
    Category_Key,
    Category
FROM products;

select * from dim_products;
-------------------------------
-- DIM_STORES
-------------------------------

CREATE OR REPLACE TABLE dim_stores AS
SELECT
    Store_Key,
    Country,
    State,
    Square_Meters,
    `Open Date` as Open_Date
FROM stores;


-------------------------------
-- DIM_EXCHANGE_RATES
-------------------------------

CREATE OR REPLACE TABLE dim_exchange_rates AS
SELECT
    Date,
    Currency,
    Exchange
FROM exchange_rates;


-------------------------------
-- DIM_DATE
-------------------------------

CREATE OR REPLACE TABLE dim_date AS
SELECT DISTINCT
    CAST(Order_Date AS DATE) AS Order_Date,
    YEAR(Order_Date) AS Year,
    QUARTER(Order_Date) AS Quarter,
    MONTH(Order_Date) AS Month,
    DATE_FORMAT(Order_Date,'MMMM') AS Month_Name,
    DAY(Order_Date) AS Day,
    WEEKOFYEAR(Order_Date) AS Week_Number,
    DATE_FORMAT(Order_Date,'EEEE') AS Weekday
FROM sales;


            ----CLEANING PART----ALL TABLES

---1 FACT_SALES TABLE 

--DATA CHECK
select * from fact_sales;
SELECT COUNT(*) FROM fact_sales;--rows 62884
--data type
describe fact_sales;
--null check
select * from fact_sales where Order_Number is null
                          or Line_Item is null
                          or Order_Date is null
                          or Delivery_Date is null
                          or Customer_Key is null
                          or Store_Key is null
                          or Product_Key is null
                          or Quantity is null
                          or Currency_Code is null;


    select count(*) from fact_sales where Delivery_Date is  null;---nulls 49719

--Missing delivery % = 79.06   
SELECT
ROUND(
COUNT(CASE WHEN delivery_date IS NULL THEN 1 END)
* 100.0 / COUNT(*),2
) AS missing_delivery_percentage
FROM fact_sales;
---A significant portion of orders (around 79%) have missing delivery dates, likely indicating pending shipments, incomplete logistics tracking, or unavailable delivery information. These records were excluded from delivery performance analysis to maintain accuracy.

--for check extar validatiion for null delivery_date= missing delivery
SELECT
CASE
WHEN Delivery_Date IS NULL
THEN 'Missing Delivery Date'
ELSE 'Delivered'
END AS delivery_status,

COUNT(*) AS total_orders

FROM fact_sales
GROUP BY delivery_status;
--delivery_status	    total_orders
--Delivered	              13165
--Missing Delivery Date	  49719

--duplicate check
SELECT
  Order_Number,
  Line_Item,
  Product_Key,
  COUNT(*) AS cnt
FROM fact_sales
GROUP BY Order_Number, Line_Item, Product_Key
HAVING COUNT(*) > 1;---no duplicate found

--2 DIM_CUSTOMERS TABLE
SELECT * FROM dim_customers;
SELECT count(*) from dim_customers;---rows 15266
--data type 
desc dim_customers;
--null check
select * from dim_customers where Customer_Key is null
                          or Gender is null
                          or Name is null
                          or City is null
                          or state_code is null
                          or State is null
                          or zip_code is null
                          or Country is null
                          or Continent is null
                          or Birthday is null; ---no nulls found
--duplicate check
SELECT
  Customer_Key,
  COUNT(*) AS cnt
FROM dim_customers
GROUP BY Customer_Key
HAVING COUNT(*) > 1;---no duplicate found

---FIND (ONLY blank + extra spaces)
SELECT *
FROM dim_customers
WHERE 
    TRIM(Name) = '' OR Name <> TRIM(Name) OR Name LIKE '%  %'
    OR TRIM(City) = '' OR City <> TRIM(City) OR City LIKE '%  %'
    OR TRIM(State) = '' OR State <> TRIM(State) OR State LIKE '%  %'
    OR TRIM(Country) = '' OR Country <> TRIM(Country) OR Country LIKE '%  %';
---17 rows found

--update and fix for 17 rows 
UPDATE dim_customers
SET
    Name = TRIM(REGEXP_REPLACE(Name, '\\s+', ' ')),
    City = TRIM(REGEXP_REPLACE(City, '\\s+', ' ')),
    State = TRIM(REGEXP_REPLACE(State, '\\s+', ' ')),
    Country = TRIM(REGEXP_REPLACE(Country, '\\s+', ' '))
WHERE
    TRIM(Name) = ''
    OR Name <> TRIM(Name)
    OR Name LIKE '%  %'
    
    OR TRIM(City) = ''
    OR City <> TRIM(City)
    OR City LIKE '%  %'
    
    OR TRIM(State) = ''
    OR State <> TRIM(State)
    OR State LIKE '%  %'
    
    OR TRIM(Country) = ''
    OR Country <> TRIM(Country)
    OR Country LIKE '%  %';

---3 DIM_PRODUCTS TABLE
--check data 
SELECT * FROM dim_products;
SELECT count(*) from dim_products;---rows 2517

--check nulls
select count(*) from dim_products where Product_Key is null
select count(*) from dim_products where Product_Name is null
select count(*) from dim_products where Brand is null
select count(*) from dim_products where Color is null
select count(*) from dim_products where Unit_Cost_USD  is null---14 nulls found
select count(*) from dim_products where Unit_Price_USD is null---158 nulls found
select count(*) from dim_products where Category is null
select count(*) from dim_products where Subcategory is null
select count(*) from dim_products where Category_Key is null
select count(*) from dim_products where Sub_category_Key is null;
                          
--update column replace with zero
update dim_products set Unit_Cost_USD = '0'
 where Unit_Cost_USD is null;

update dim_products set Unit_Price_USD = '0'
 where Unit_Price_USD is null;
---duplicate check
select product_key, count(*) from dim_products 
group by product_key
having count(*) > 1;-- NO DUPLICATES

select distinct brand from dim_products;--11 brands
select distinct color from dim_products;--16 colors



 ---4 DIM_STORE TABLE
 select * from dim_stores;
 select count(*) from dim_stores;--67 rows

 -- check nulls
select count(*) from dim_stores where Store_Key is null
select count(*) from dim_stores where country is null
select count(*) from dim stores where state is null
select count(*) from dim_stores where square_meters is null--- one null found
select count(*) from dim_stores where open_date is null

--one null fix with 0
update dim_stores
set square_meters = '0'
where square_meters is null;

--check duplicate
select store_key, count(*) from dim_stores
group by store_key
having count(*) > 1;---no duplicate

select distinct country from dim_stores;---9 countries
select distinct state from dim_stores;---67 state 
---future data check
  select count(*)  from dim_stores where Open_Date > current_date();

  ----5 DIM_EXCHANGE TABLE
  SELECT * from dim_exchange_rates;
  select count(*) from dim_exchange_rates;--rows 11215
  --null check
  select count(*) from dim_exchange_rates where date is null;
  select count(*) from dim_exchange_rates where currency is null;
  select count(*) from dim_exchange_rates where exchange is null;

  --duplicate check
  select date, currency, exchange, count(*) from dim_exchange_rates
  group by date, currency, exchange
  having count(*) > 1;-- no duplicate

  select distinct currency from dim_exchange_rates;--5 types of currency
  select min(date), max(date) from dim_exchange_rates;

  ---negative value check
  select * from dim_exchange_rates where exchange < 0;--no negative value

----6 dim_date table
select * from dim_date;
select count(*) from dim_date;---1641 rows

---null check
select * from dim_date where order_Date is null;
select * from dim_date where Year is null;
select * from dim_date where Quarter is null;
select * from dim_date where Month is null;
select * from dim_date where Month_Name is null;
select * from dim_date where Day is null;
select * from dim_date where Week_Number is null;
select * from dim_date where Weekday is null;
--no nulls

--duplicate check
select order_Date, Year, Quarter, Month, Month_Name, Day, week_Number, Weekday, count(*) from dim_date
group by order_Date, Year, Quarter, Month, Month_Name, Day, week_Number, Weekday
having count(*) > 1;--no duplicate



       ---------ANALYSIS PART------

---total revenue = $43202936.17
select  round(sum(f.quantity * p.unit_price_usd),2) as revenue
from sales f
inner join dim_products p
on f.product_key = p.product_key;

---total_profit = $20538473.84
select round(sum(f.quantity * p.unit_price_usd) - (sum(f.quantity * p.unit_cost_usd)),2) as profit
from sales f
inner join dim_products p
on f.product_key = p.product_key;  ---profit = selling - cost 

--total orderrs = 26326
select count(distinct order_number) as total_orders from fact_sales;
--total customers = 11887
select count(distinct customer_key) as total_customers from fact_sales;
--total quantity sold = 197757
select sum(quantity) as total_quantity_sold from fact_sales;
--average order per customers = 2.21
select round(count(distinct order_number)/count(distinct customer_key),2) as avg_order_per_customer from fact_sales;
--average revenue per order= 1614.07 
select round(sum(f.quantity * p.unit_price_usd)/count(distinct order_number),2) as avg_revenue_per_order from sales f
left join dim_products p
on f.product_key = p.product_key;

---all brand name 
select distinct brand from dim_products;
--INSIGHTS
 --BRAND;-                                      
--Proseware                                
--Tailspin Toys
--Wide World Importers
--A. Datum
--Litware
--Contoso
--Fabrikam
--Adventure Works
--The Phone Company
--Northwind Traders
--Southridge Video

----ALL colors name
select distinct color from dim_products;
--Blue, Green, Black, Orange, Grey, Gold, Azure, Purple, Silver, Brown, Transparent, Yellow, Red, Pink, White, Silver,  Grey

--top products
select p.product_name, sum(f.quantity *  p.unit_price_usd) as revenue
from sales f
left join dim_products p
on f.product_key = p.product_key
group by p.product_name
order by revenue desc
limit 10;
---insighgts
--product_name	                                   revenue
--WWI Desktop PC2.33 X2330 Black	               $505450
--Adventure Works Desktop PC2.33 XD233 Silver	   $466089
--Adventure Works Desktop PC2.33 XD233 Brown	   $464151
--Adventure Works Desktop PC2.33 XD233 Black	   $447678
--Adventure Works Desktop PC2.33 XD233 White	   $437019
--WWI Desktop PC2.33 X2330 White	               $424578
--WWI Desktop PC2.33 X2330 Brown	               $422740
--WWI Desktop PC2.33 X2330 Silver	               $360248
--Adventure Works Desktop PC2.30 MD230 White	   $312079
--Adventure Works Desktop PC2.30 MD230 Black	   $307886

--CATEGORY WISE REVENUE
SELECT p.category, round(sum(f.quantity * p.unit_price_usd),2) as revenue
FROM sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;
--insights
--category	                      revenue
--Computers	                     16074579.46
--Cell phones	                 6183791.22
--Home Appliances	             5886896.63
--Cameras and camcorders	     5284588.02
--Audio	                         3169627.74
--Music, Movies and Audio Books	 3131006.44
--TV and Video	                 2747617.23
--Games and Toys	             724829.43

---BRAND WISE REVENUE
SELECT p.brand, round(sum(f.quantity * p.unit_price_usd),2) as revenue
FROM sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.brand
ORDER BY revenue DESC;
---insights
---Brand                         Revenue
---Adventure Works	             8151804.86
--Wide World Importers	         8136600.41
--Contoso	                     7919096.32
--The Phone Company	             5386820
--Fabrikam	                     4478974.92 
--Southridge Video	             2578595.93
--Proseware	                     2270394.02
--Litware	                     1511139.42
--A. Datum	                     1486207.8
--Tailspin Toys	                 682730.95
--Northwind Traders	             600571.54

--STATE WISE REVENUE
SELECT s.state, round(sum(f.quantity * p.unit_price_usd),2) as revenue
FROM sales f
LEFT JOIN dim_stores s
ON f.Store_key = s.Store_key
LEFT JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY s.state
ORDER BY revenue DESC
LIMIT 5;
--insights
--state	        revenue
--Online	    8939293.31
--Connecticut	1080185.07
--Nebraska	    1074492.82
--Northwest Territories	1063037.26
--Kansas	     1058078.43

---gender wise revenue
select c.gender, round(sum(f.quantity * p.unit_price_usd),2) as revenue
from sales f
left join dim_customers c
on f.customer_key = c.customer_key
left join dim_products p
on f.product_key = p.product_key
group by c.gender
order by revenue desc;
--insights
--gender	   revenue
--Male	       21798500.61
--Female	   21404435.56

----city wise revenue top 5
SELECT c.city, round(sum(f.quantity * p.unit_price_usd),2) as revenue
FROM sales f
LEFT JOIN dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN dim_products p
ON f.product_key = p.product_key
group by c.City
order by revenue desc
limit 5;
--insight
--city	       revenue
--Toronto	   474615.27
--New York	   389239.53
--Los Angeles	381105.45
--Houston	    285023.31
--Philadelphia	275510.12

--top 5 revenue by customer name
select c.name, round(sum(f.quantity * p.unit_price_usd ),2) as revenue from fact_sales f
left join dim_customers c
on f.customer_key = c.customer_key
left join dim_products p
on f.product_key = p.product_key
group by c.name
order by revenue desc
limit 5;
--insight
--name	                revenue
--Michael Robertson	    36664.3
--Paul Warren	        34671.33
--Gaspare Trevisan	    34425.03
--Lillian Evans	        29051
--Claire Macdonald	    28869.45


---top 5 stores
SELECT
    s.Store_Key,

ROUND(SUM(f.Quantity * p.Unit_Price_USD),2)
AS Revenue

FROM fact_sales f

LEFT JOIN dim_stores s
ON f.Store_Key = s.Store_Key

LEFT JOIN dim_products p
ON f.Product_Key = p.Product_Key

GROUP BY s.Store_Key
ORDER BY Revenue DESC
LIMIT 5;
---Store_Key	    Revenue
---Store_Key	    Revenue
---0	            8939293.31
---45	            1080185.07
---54	            1074492.82
---9	            1063037.26
---50	            1058078.43

---average delivery date = 4.53
select round(avg(datediff(delivery_date,order_date)),2) as avg_del_date from fact_sales;

---how many orders are delayed by more than 7 days ?
select count(*) as orders from fact_sales 
where datediff(delivery_date,order_date) > 7;
--1135 orders delayed mor than 7 days
---indicating the potenetinal issues in the delivery or logistics process


--PROFIT BY CATEGORY
select p.category, round(sum(f.quantity * p.unit_price_usd - f.quantity * p.unit_cost_usd),2) as profit from fact_sales f
left join dim_products p
on f.product_key = p.product_key
group by p.category
order by profit desc;
---category	                profit
--Computers	                8050431.9
--Cell phones	            3498626.54
--Cameras and camcorders	2684220.99
--Music, Movies and Audio Books	1909259.17
--Audio	                     1827851.77
--Home Appliances	         1816085.77
--Games and Toys	         396668.77
--TV and Video	             355328.93

--total_repeat customers = 7272
SELECT
COUNT(*) AS Repeat_Customers
FROM
(SELECT Customer_Key
FROM fact_sales
GROUP BY Customer_Key
HAVING COUNT(DISTINCT Order_Number) > 1) u;

--check exchange rate trend
select date, currency,  exchange from dim_exchange_rates
order by currency, date;

--average exchange rate
select currency, round(avg(exchange),2) as avg_exchange_rate from dim_exchange_rates
group by currency
order by avg_exchange_rate desc;
---currency	          avg_exchange_rate
--AUD	                       1.37
--CAD	                       1.31
--USD	                       1
--EUR	                       0.88
--GBP	                       0.75

--maximum and minimum exchange rate
SELECT
Currency,
round(MAX(Exchange),2) as max_exchange_rate,
round(min(Exchange),2) AS min_Exchange_Rate
FROM dim_exchange_rates
GROUP BY Currency
ORDER BY max_exchange_rate, min_exchange_rate desc;

--Currency	max_exchange_rate	min_Exchange_Rate
--GBP	      0.86	                      0.63
--EUR	     0.96	                       0.8
--USD	     1	                            1
--CAD	     1.46	                       1.16
--AUD	     1.73	                       1.21

-- year wise currency exchange trend
SELECT
YEAR(Date) AS Year,
Currency,
ROUND(AVG(Exchange),2)
AS Avg_Exchange_Rate
FROM dim_exchange_rates
GROUP BY YEAR(Date), Currency
ORDER BY Year, Currency;

---currency flactuate
select currency,   round((max(exchange) - min(exchange)),2) as flactuate from dim_exchange_rates
group by Currency
order  by flactuate;
--currency	flactuate
--USD	      0
--EUR	     0.16
--GBP	     0.23
--CAD	     0.31
--AUD	     0.52

---TIME ANALYSIS
---year wise revenue
select d.year, round(sum(f.quantity * p.unit_price_usd),2) as revenue from fact_sales f
left join dim_products p
on f.product_key = p.product_key
left join dim_date d
on f.order_date = d.Order_date
group by d.year
order by d.year;
--year	revenue
--2016	4792277.18
--2017	5654536.98
--2018	9870646.05
--2019	14654692.38
--2020	7378507.45
--2021	852276.13

--year wise profit
select d.year, round(sum(f.quantity * p.unit_price_usd - f.quantity * p.unit_cost_usd),2) as profit from fact_sales f
left join dim_products p
on f.product_key = p.product_key
left join dim_date d
on f.order_date = d.Order_date
group by d.year
order by d.year;
--year	profit
--2016	2033060.81
--2017	2634852.19
--2018	4666451.36
--2019	7202552.56
--2020	3580105.58
--2021	421451.34

--quater wise revenue
SELECT 
    d.Year,
    d.Quarter,
    ROUND(SUM(f.Quantity * p.Unit_Price_USD),2) AS Revenue
FROM fact_sales f
LEFT JOIN dim_date d
ON f.Order_Date = d.Order_Date
LEFT JOIN dim_products p
ON f.Product_Key = p.Product_Key
GROUP BY d.Year, d.Quarter
ORDER BY d.Year, d.Quarter;
--The 2020 Pivot: Revenue peaked spectacularly in Q4 2019 at 4.60M, but experienced a massive, consecutive decline starting Q2 2020, bottoming out at 852K by Q1 2021—wiping out nearly 4 years of growth.
--Seasonal Peak: Between 2016 and 2019, the business followed a highly predictable seasonal pattern where Q4 was consistently the strongest quarter, driven by massive end-of-year surges.

--month wise trend
SELECT 
    d.Month_Name,
    ROUND(SUM(f.Quantity * p.Unit_Price_USD),2) AS Revenue
FROM fact_sales f
LEFT JOIN dim_date d
ON f.Order_Date = d.Order_Date
LEFT JOIN dim_products p
ON f.Product_Key = p.Product_Key
GROUP BY  d.Month_Name
ORDER BY d.Month_Name;
--december is the highest revenue $5870975.98

--weekday wise revenue
SELECT 
    d.Weekday,
    ROUND(SUM(f.Quantity * p.Unit_Price_USD),2) AS Revenue
FROM fact_sales f
LEFT JOIN dim_date d
ON f.Order_Date = d.Order_Date
LEFT JOIN dim_products p
ON f.Product_Key = p.Product_Key
GROUP BY d.Weekday
ORDER BY Revenue DESC;
--saturday is the highest revenue day
--Weekday	Revenue
--Saturday	10181243.01
--Thursday	8309233.28
--Wednesday	7588516.71
--Tuesday	5958542.78
--Friday	5818796.84
--Monday	4597421.44
--Sunday	749182.11

---mom growth percentage %

WITH monthly_sales AS (
SELECT
d.Month_Name,
ROUND(SUM(f.Quantity * p.Unit_Price_USD),2) AS Revenue FROM fact_sales f
LEFT JOIN dim_date d
ON f.Order_Date = d.Order_Date
LEFT JOIN dim_products p
ON f.Product_Key = p.Product_Key
GROUP BY  d.Month_Name)

SELECT
Month_name
Revenue,
LAG(Revenue) OVER(ORDER BY month_name) AS Previous_month_Revenue,
ROUND(
((Revenue - LAG(Revenue) OVER(ORDER BY  Month_name))
/ LAG(Revenue) OVER(ORDER BY  Month_name)) * 100,2
) AS MOM_Growth_Percentage

FROM monthly_sales;

--Revenue	Previous_month_Revenue	            MOM_Growth_Percentage
--April	         null	                               null
--August	     463120.49	                           584.25
--December	     3168905.82	                           85.27
--February	     5870975.98	                            0.41
--January	      5894975.5	                           -9.76
--July	          5319790.56	                         -43.15
--June	          3024103.29	                         12.88
--March	          3413754.61	                         -43.65
--May	          1923509.54	                           90.5
--November	      3664234.3	                             -3.35
--October	    3541332.17	                             -0.31
--September	     3530393.79	                              -4.04

---yoy growth % 
WITH yearly_sales AS (
SELECT 
    d.Year,
    ROUND(SUM(f.Quantity * p.Unit_Price_USD),2) AS Revenue
FROM fact_sales f
LEFT JOIN dim_date d
ON f.Order_Date = d.Order_Date
LEFT JOIN dim_products p
ON f.Product_Key = p.Product_Key
GROUP BY d.Year)

SELECT
Year,
Revenue,
LAG(Revenue) OVER(ORDER BY Year) AS Previous_Year_Revenue,
ROUND(
((Revenue - LAG(Revenue) OVER(ORDER BY Year))
/ LAG(Revenue) OVER(ORDER BY Year)) * 100,2
) AS YoY_Growth_Percentage

FROM yearly_sales;

---insights
--The Explosive Growth Phase (2017–2019): The business experienced massive acceleration, peaking in 2018 with a staggering 74.56% YoY growth. By 2019, revenue reached its absolute highest point at $14.65M, nearly tripling the 2016 baseline.
--The Post-2019 Crash (2020–2021): The trajectory reversed aggressively after 2019. Revenue was cut roughly in half in 2020 (-49.65%), followed by a near-total collapse in 2021, plummeting by -88.45% to just $852K.


--Store Size vs Revenue
SELECT
s.Store_Key,
s.Square_Meters,

ROUND(
SUM(f.Quantity * p.Unit_Price_USD),2
) AS Revenue

FROM fact_sales f

LEFT JOIN dim_stores s
ON f.Store_Key = s.Store_Key

LEFT JOIN dim_products p
ON f.Product_Key = p.Product_Key

WHERE s.Square_Meters IS NOT NULL

GROUP BY s.Store_Key, s.Square_Meters

ORDER BY Revenue DESC;
--Store_Key 0 generated the highest revenue ($8.94M) despite having 0 square meters, indicating it likely represents online sales rather than a physical retail store.
--Several medium-sized stores (around 1,200–2,000 sq. meters) consistently produced strong revenue, suggesting that store efficiency and location may impact sales more than store size alone.





