
use  customer_behaviour

select  * from customer

/*gender wise revenue generated*/
select gender, count(*) as total_transactions,
sum(purchase_amount) as total_revenue from customer group by gender

/*customers used a discount but still spent more than avg purchase amount*/
select customer_id,purchase_amount from customer
where 
discount_applied='Yes' and purchase_amount>= (select avg(purchase_amount) from customer)

/* top 5 productd with highest average review rating*/

select top 5 item_purchased, round(avg(review_rating),2) as 'Average product rating' 
from customer group by item_purchased order by avg(review_rating) desc

/*compare the average purchase amount btw Standard and Express Shipping*/
select shipping_type, avg(purchase_amount)  from customer
where shipping_type in ('Standard','Express')
group by shipping_type

/*do subscribed customers spend more? compare avg spend and total revenue btw them*/
select subscription_status, count(customer_id) as "Total Customers",
sum(purchase_amount) as "Total Revenue", round(avg(purchase_amount),3) as "Average Spend"
from customer
group by subscription_status
order by "Total Revenue","Average Spend" desc

/*which 5 products have highest percent of purchase with discount applied*/

select top 5 item_purchased,
100 * sum(case when discount_applied = 'Yes' then 1 else 0 END)/count(*)  as 'Discount Rate' from customer
group by item_purchased order by 'Discount Rate' desc

/*Segmemt customers into new, returning and loyal based on total number of previous purchase and show count of each segment*/

with customer_type as
(
SELECT customer_id,previous_purchases,
       CASE
           WHEN previous_purchases = 1 THEN 'New'
           WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
           ELSE 'Loyal'
       END AS Customer_Segment
FROM customer
)
select Customer_segment, count(*) as "Number of Customers"
from customer_type group by Customer_Segment
order by "Number of Customers" desc

/*top 3 purchased products within each category*/

WITH ITEM_COUNT AS
(
SELECT CATEGORY, ITEM_PURCHASED, COUNT(CATEGORY) AS 'PRODUCTS_SOLD',
ROW_NUMBER() OVER (PARTITION BY CATEGORY ORDER BY COUNT(CATEGORY) DESC) AS 'PRODUCT_RANK'
FROM CUSTOMER 
GROUP BY CATEGORY,ITEM_PURCHASED 
)
SELECT CATEGORY, ITEM_PURCHASED, PRODUCTS_SOLD, PRODUCT_RANK
FROM ITEM_COUNT 
WHERE PRODUCT_RANK <= 3

/*ARE CUSTOMER WHO ARE REPEAT BUYERS (>5 PREVIOUS PURCHASES) ALSO LIKELY TO SUBSCRIBE*/ 

SELECT SUBSCRIPTION_STATUS,
COUNT(CUSTOMER_ID) AS 'REPEAT BUYERS' FROM CUSTOMER
WHERE previous_purchases>5
GROUP BY subscription_status 

select  * from customer

/*REVENUE BY AGE GROUP*/

SELECT AGE_GROUP, SUM(PURCHASE_AMOUNT) AS 'TOTAL REVENUE' FROM CUSTOMER
GROUP BY AGE_GROUP ORDER BY 'TOTAL REVENUE' DESC