-- Revenue & Profit --
-- Revenue & Profit each year
SELECT
	date_part('year', order_date) as year_order,
	SUM(sales) as Revenue,
	SUM(profit) as Profit
FROM superstore_sales
GROUP BY 1
ORDER BY 1 ASC
;

-- Total of return order each year
SELECT
	date_part('year', sal.order_date) as year_order,
	COUNT(ret.order_id) AS total_return
FROM superstore_sales as sal
LEFT JOIN returns as ret
ON sal.order_id = ret.order_id
GROUP BY 1
ORDER BY 1 ASC
;


-- CUSTOMER --
-- Average Monthly Active User (MAU) per year
SELECT
	year_order,
	CAST(AVG(mau) AS NUMERIC(36, 2)) as monthly_active_user
FROM(
SELECT
	date_part('year', order_date) as year_order,
	date_part('month', order_date) as month_order,
	COUNT(DISTINCT customer_id) as mau
FROM superstore_sales
GROUP BY 1,2
) mau_year
GROUP BY 1
;

-- Total new customer per year
SELECT
	first_year_order as year_order,
	COUNT(customer_id) as new_customer
FROM (
	SELECT
		customer_id,
		MIN(date_part('year', order_date)) as first_year_order
	FROM superstore_sales
	GROUP BY 1
) newcus
GROUP BY 1
ORDER BY 1 ASC
;

-- Total repeat order of each customer per year
SELECT
	year_order,
	COUNT(customer_id) as customer_repeat_order
FROM (
	SELECT
		date_part('year', order_date) as year_order,	
		customer_id,
		COUNT(order_id) as total_order
	FROM superstore_sales
	GROUP BY 1,2
	HAVING COUNT(order_id) > 1
) cus_ord
GROUP BY 1
ORDER BY 1 ASC
;

-- The average transaction / order made by customers every year
SELECT
	year_order,
	CAST(AVG(total_order) AS NUMERIC(36, 2)) as average_order
FROM (
	SELECT
		date_part('year', order_date) as year_order,	
		customer_id,
		COUNT(order_id) as total_order
	FROM superstore_sales
	GROUP BY 1,2
) cus_ord
GROUP BY 1
ORDER BY 1 ASC
;

-- The Segment of customer with its revenue, profit, and return each year
SELECT
	date_part('year', sal.order_date) as year_order,
	cus.segment,
	SUM(sal.sales) as revenue,
	SUM(sal.profit) as profit,
	COUNT(ret.returned) as total_return,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.sales) DESC) AS rank_segment
FROM superstore_sales as sal
INNER JOIN superstore_customer as cus
ON sal.customer_id = cus.customer_id
INNER JOIN returns as ret
ON sal.order_id = ret.order_id
GROUP BY 1,2
ORDER BY 1
;


-- The Top & Bottom Market of customer with its revenue each year
-- Top
WITH rank_rev AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	sal.market,
	SUM(sal.sales) as revenue,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.sales) DESC) AS rank_market
FROM superstore_sales as sal
GROUP BY 1,2
)
SELECT *
FROM rank_rev
WHERE rank_market = 1;

-- Bottom
WITH rank_rev AS (
SELECT
	date_part('year', sal.order_date) as
	year_order,
	sal.market,
	SUM(sal.sales) as revenue,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.sales) ASC) AS rank_market
FROM superstore_sales as sal
GROUP BY 1,2
)
SELECT *
FROM rank_rev
WHERE rank_market = 1
;

-- The Top & Bottom Market of customer with its profit each year
-- Top
WITH rank_prof AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	sal.market,
	SUM(sal.profit) as profit,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.profit) DESC) AS rank_market
FROM superstore_sales as sal
GROUP BY 1,2
)
SELECT *
FROM rank_prof
WHERE rank_market = 1
;

-- Bottom
WITH rank_prof AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	sal.market,
	SUM(sal.profit) as revenue,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.profit) ASC) AS rank_market
FROM superstore_sales as sal
GROUP BY 1,2
)
SELECT *
FROM rank_prof
WHERE rank_market= 1
;

-- The Top & Bottom Market of customer with its return order each year
-- Top
WITH rank_retor AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	sal.market,
	COUNT(ret.returned) as total_return,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY COUNT(ret.returned) DESC) AS rank_market
FROM superstore_sales as sal
LEFT JOIN returns as ret
ON sal.order_id = ret.order_id
GROUP BY 1,2
)
SELECT *
FROM rank_retor
WHERE rank_market = 1
;


-- Bottom
WITH rank_retor AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	sal.market,
COUNT(ret.returned) as total_return,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY COUNT(ret.returned) ASC) AS rank_market
FROM superstore_sales as sal
LEFT JOIN returns as ret
ON sal.order_id = ret.order_id
GROUP BY 1,2
)
SELECT *
FROM rank_retor
WHERE rank_market = 1
;


-- PRODUCT--
-- The Top Category with its revenue each year
WITH top_cat_rev AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.category,
	SUM(sal.sales) as revenue,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.sales) DESC) AS rank_cat
FROM superstore_sales as sal
LEFT JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT *
FROM top_cat_rev
WHERE rank_cat = 1
;

-- The Top Category with its profit each year
WITH top_cat_prof AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.category,
SUM(sal.profit) as profit,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.profit) DESC) AS rank_cat
FROM superstore_sales as sal
LEFT JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT *
FROM top_cat_prof
WHERE rank_cat = 1
;


-- The Top Category with its returns each year
WITH top_cat_ret AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.category,
	COUNT(ret.returned) as total_return,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY COUNT(ret.returned) DESC) AS rank_cat
FROM superstore_sales as sal
INNER JOIN superstore_product as prod
ON sal.product_id = prod.product_id
INNER JOIN returns as ret
ON sal.order_id = ret.order_id
GROUP BY 1,2
)
SELECT *
FROM top_cat_ret 
WHERE rank_cat = 1
;

select * from superstore_product where sub_category = 'Machines';
select distinct category, sub_category from superstore_product;

-- The Top Sub Category with its revenue each year
WITH top_sub_cat_rev AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	SUM(sal.sales) as revenue,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.sales) DESC) AS rank_sub_cat
FROM superstore_sales as sal
INNER JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT *
FROM top_sub_cat_rev
WHERE rank_sub_cat = 1
;

-- The Bottom Sub Category with its revenue each year
WITH bottom_sub_cat_rev AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	SUM(sal.sales) as revenue,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.sales) ASC) AS rank_sub_cat
FROM superstore_sales as sal
INNER JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT *
FROM bottom_sub_cat_rev
WHERE rank_sub_cat = 1
;

-- The Top Sub Category with its revenue each year
WITH top_sub_cat_prof AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	SUM(sal.profit) as profit,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.profit) DESC) AS rank_sub_cat
FROM superstore_sales as sal
INNER JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT *
FROM top_sub_cat_prof
WHERE rank_sub_cat = 1
;

-- The Bottom Sub Category with its revenue each year
WITH bottom_sub_cat_prof AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	SUM(sal.profit) as profit,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.profit) ASC) AS rank_sub_cat
FROM superstore_sales as sal
INNER JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT *
FROM bottom_sub_cat_prof
WHERE rank_sub_cat = 1
;

-- The Top Sub Category with its returns each year
WITH top_sub_cat_ret AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	COUNT(ret.returned) as total_return,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY COUNT(ret.returned) DESC) AS rank_sub_cat
FROM superstore_sales as sal
INNER JOIN superstore_product as prod
ON sal.product_id = prod.product_id
INNER JOIN returns as ret
ON sal.order_id = ret.order_id
GROUP BY 1,2
)
SELECT *
FROM top_sub_cat_ret
where 
	rank_sub_cat = 1
;

-- The Bottom Sub Category with its returns each year
WITH bottom_sub_cat_ret AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	COUNT(ret.returned) as total_return,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY COUNT(ret.returned) ASC) AS rank_sub_cat
FROM superstore_sales as sal
INNER JOIN superstore_product as prod
ON sal.product_id = prod.product_id
INNER JOIN returns as ret
ON sal.order_id = ret.order_id
GROUP BY 1,2
)
SELECT *
FROM bottom_sub_cat_ret
where 
	rank_sub_cat = 1
;


-- The Category with profit > 0 and average discount per year
WITH rank_cat_disc_up AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.category,
	SUM(sal.profit) as profit,
	CAST(AVG(sal.discount) AS NUMERIC(36, 2)) as average_discount,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.profit) DESC) AS rank_cat
FROM superstore_sales as sal
LEFT JOIN superstore_product as prod
ON sal.product_id = prod.product_id
WHERE sal.profit > 0
GROUP BY 1,2
)
SELECT *
FROM rank_cat_disc_up
;

-- The Category with profit < 0 and average discount per year
WITH rank_cat_disc_down AS (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.category,
	SUM(sal.profit) as profit,
	CAST(AVG(sal.discount) AS NUMERIC(36, 2)) as average_discount,
	rank() OVER (PARTITION BY date_part('year', sal.order_date) ORDER BY SUM(sal.sales) DESC) AS rank_cat
FROM superstore_sales as sal
LEFT JOIN superstore_product as prod
ON sal.product_id = prod.product_id
WHERE sal.profit < 0
GROUP BY 1,2
)
SELECT *
FROM rank_cat_disc_down
;

-- Transcation per sub_category
WITH tmp as (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	COUNT(sal.order_id) as total_order
FROM superstore_sales as sal
LEFT JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT 
	sub_category,
	SUM(CASE WHEN year_order = '2011' THEN total_order ELSE 0 END) AS year_2011, 
	SUM(CASE WHEN year_order = '2012' THEN total_order ELSE 0 END) AS year_2012, 
	SUM(CASE WHEN year_order = '2013' THEN total_order ELSE 0 END) AS year_2013,
	SUM(CASE WHEN year_order = '2014' THEN total_order ELSE 0 END) AS year_2014
FROM tmp
GROUP BY 1;


-- Average discount per sub_category
WITH avg_disc_sub as (
SELECT
	date_part('year', sal.order_date) as year_order,
	prod.sub_category,
	CAST(AVG(sal.discount) AS NUMERIC(36, 2)) as average_discount
FROM superstore_sales as sal
LEFT JOIN superstore_product as prod
ON sal.product_id = prod.product_id
GROUP BY 1,2
)
SELECT 
	sub_category,
	SUM(CASE WHEN year_order = '2011' THEN average_discount ELSE 0 END) AS year_2011, 
	SUM(CASE WHEN year_order = '2012' THEN average_discount ELSE 0 END) AS year_2012, 
	SUM(CASE WHEN year_order = '2013' THEN average_discount ELSE 0 END) AS year_2013,
	SUM(CASE WHEN year_order = '2014' THEN average_discount ELSE 0 END) AS year_2014
FROM avg_disc_sub
GROUP BY 1;

select * from superstore_sales limit 5;
select * from superstore_product limit 5;

-- SHIPMENT --
-- The average, min and max shipment cost per year
SELECT
	date_part('year', ship_date) as year_order,
	AVG(shipping_cost) as average_shipment_cost,
	MAX(shipping_cost) as max_shipment_cost,
	MIN(shipping_cost) as min_shipment_cost
FROM superstore_ship 
GROUP BY 1
ORDER BY 1 ASC
;

-- The average, min and max shipment day per year
SELECT
	date_part('year', ship_date) as year_order,
	AVG(ship_date - order_date) as average_shipment_day,
	MAX(ship_date - order_date) as max_shipment_day,
	MIN(ship_date - order_date) as min_shipment_day
FROM superstore_ship 
GROUP BY 1
ORDER BY 1 ASC
;

-- The average shipment day, cost, revenue & profit per segment & year
SELECT
	date_part('year', shp.ship_date) as year_order,
	cus.segment,
	AVG(shp.ship_date - shp.order_date) as average_shipment_day,
	AVG(shp.shipping_cost) as average_shipment_cost,
	AVG(sal.sales) as average_revenue,
	AVG(sal.profit) as average_profit
FROM superstore_ship as shp
INNER JOIN superstore_customer as cus
ON shp.customer_id = cus.customer_id
INNER JOIN superstore_sales as sal
ON shp.order_id = sal.order_id
GROUP BY 1,2
ORDER BY 1 ASC
;

--The average shipment day, cost, revenue & profit per ship mode & year
SELECT
	date_part('year', shp.ship_date) as year_order,
	shp.ship_mode,
	AVG(shp.ship_date - shp.order_date) as average_shipment_day,
	AVG(shp.shipping_cost) as average_shipment_cost,
	AVG(sal.sales) as average_revenue,
	AVG(sal.profit) as average_profit
FROM superstore_ship as shp
INNER JOIN superstore_customer as cus
ON shp.customer_id = cus.customer_id
INNER JOIN superstore_sales as sal
ON shp.order_id = sal.order_id
GROUP BY 1,2
ORDER BY 1 ASC
;

--The average shipment day, cost, revenue & profit per priority & year
SELECT
	date_part('year', shp.ship_date) as year_order,
	shp.order_priority,
	AVG(shp.ship_date - shp.order_date) as average_shipment_day,
	AVG(shp.shipping_cost) as average_shipment_cost,
	AVG(sal.sales) as average_revenue,
	AVG(sal.profit) as average_profit
FROM superstore_ship as shp
INNER JOIN superstore_customer as cus
ON shp.customer_id = cus.customer_id
INNER JOIN superstore_sales as sal
ON shp.order_id = sal.order_id
GROUP BY 1,2
ORDER BY 1 ASC
;


-- Shipment mode with highest return order per year
SELECT
	date_part('year', shp.ship_date) as year_order,
	shp.ship_mode,
	COUNT(ret.order_id) as total_return
FROM superstore_ship as shp
LEFT JOIN returns as ret
ON shp.order_id = ret.order_id
GROUP BY 1,2
ORDER BY 1 ASC
;


SELECT
	ship_date - order_date as ship_day
FROM superstore_ship 
ORDER BY 1 DESC
limit 10
;

select * from superstore_sales limit 5;
select * from superstore_customer limit 5;
select * from superstore_product limit 5;
select * from superstore_ship limit 5;
select * from returns limit 5;





