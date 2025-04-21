-- Magist has allowed us to access a snapshot of their database. The data might have the answer to these concerns.
use magist;

-- General Questions

-- How many orders are there in the dataset?

SELECT 
    COUNT(*)
FROM
    orders;

-- Are orders actually delivered?

SELECT 
    order_status,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            orders) * 100 AS order_percentage
FROM
    orders
GROUP BY order_status;

-- Is Magist having user growth?

SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM
    orders
GROUP BY year_ , month_
ORDER BY year_ , month_;

-- How many products are there on the products table?

SELECT 
    COUNT(product_id)
FROM
    products;

-- How many of those products were present in actual transactions? 

select count(distinct product_id) from order_items;

SELECT 
    COUNT(DISTINCT product_id) / (SELECT 
            COUNT(product_id)
        FROM
            products)
FROM
    order_items;


-- What’s the price for the most expensive and cheapest products?

SELECT 
    MIN(price) AS cheapest, 
    MAX(price) AS most_expensive
FROM 
	order_items;

-- What are the highest and lowest payment values?

SELECT 
    MAX(payment_value), MIN(payment_value)
FROM
    order_payments
WHERE
    payment_value != 0;
    
-- In relation to the products

-- What categories of tech products does Magist have?

SELECT 
    *
FROM
    product_category_name_translation
WHERE
    product_category_name_english IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony');
	

-- How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?


SELECT 
    COUNT(oi.product_id) AS count_tech
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    product_category_name_translation pnt USING (product_category_name)
WHERE
    pnt.product_category_name_english IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony');

SELECT 
    (SELECT 
            COUNT(oi.product_id)
        FROM
            order_items oi
                JOIN
            products p USING (product_id)
                JOIN
            product_category_name_translation pnt USING (product_category_name)
        WHERE
            pnt.product_category_name_english IN ('audio' , 'cds_dvds_musicals',
                'consoles_games',
                'electronics',
                'dvds_blu_ray',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'tablets_printing_image',
                'telephony',
                'fixed_telephony')) / COUNT(product_id) AS percentage_sold
FROM
    order_items;

-- What’s the average price of the products being sold?

SELECT 
    AVG(oi.price)
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    product_category_name_translation pnt USING (product_category_name)
WHERE
    pnt.product_category_name_english IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony');

-- Are expensive tech products popular?

-- count
SELECT 
    COUNT(oi.product_id) AS count_expensive
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    product_category_name_translation pnt USING (product_category_name)
WHERE
    pnt.product_category_name_english IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony')
        AND oi.price > (SELECT 
            AVG(oi.price)
        FROM
            order_items oi
                JOIN
            products p USING (product_id)
                JOIN
            product_category_name_translation pnt USING (product_category_name)
        WHERE
            pnt.product_category_name_english IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony'));
                
-- Percentage
WITH TechCategoryItems AS (
    SELECT
        oi.product_id,
        oi.price
    FROM
        order_items oi
    JOIN
        products p USING (product_id)
    JOIN
        product_category_name_translation pnt USING (product_category_name)
    WHERE
        pnt.product_category_name_english IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony')
),
TechCategoryAvgPrice AS (
    SELECT
        AVG(price) AS avg_price
    FROM
        TechCategoryItems
),
ExpensiveTechCount AS (
    SELECT
        COUNT(tci.product_id) AS count_expensive
    FROM
        TechCategoryItems tci
    JOIN
        TechCategoryAvgPrice tcap ON tci.price > tcap.avg_price
),
TotalTechCount AS (
    SELECT
        COUNT(product_id) AS count_tech
    FROM
        TechCategoryItems
)
SELECT
    CAST(etc.count_expensive AS REAL) / ttc.count_tech AS percentage_of_expensive_tech_sold
FROM
    ExpensiveTechCount etc,
    TotalTechCount ttc;
    
-- In relation to the sellers

-- How many months of data are included in the magist database?

SELECT 
    COUNT(*)
FROM
    (SELECT DISTINCT
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS year_month_
    FROM
        orders) a;

SELECT DISTINCT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS year_month_
FROM
    orders
ORDER BY year_month_;

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?

-- Seller count
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    order_items;

-- Tech Seller Count
SELECT 
    COUNT(DISTINCT seller_id) as tech_seller
FROM
    order_items
        JOIN
    products USING (product_id)
        JOIN
    product_category_name_translation USING (product_category_name)
WHERE
    product_category_name IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony');

-- Tech Seller Percentage
select (tech_seller/ (SELECT 
    COUNT(DISTINCT seller_id)
FROM
    order_items)) as Tech_percentage 
    From 
    (SELECT 
    COUNT(DISTINCT seller_id) as tech_seller
FROM
    order_items
        JOIN
    products USING (product_id)
        JOIN
    product_category_name_translation USING (product_category_name)
WHERE
    product_category_name IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony')) a;

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?

select sum(price) from order_items;

SELECT 
    SUM(price)
FROM
    order_items
        JOIN
    products USING (product_id)
        JOIN
    product_category_name_translation USING (product_category_name)
WHERE
    product_category_name IN ('audio' , 'cds_dvds_musicals',
        'consoles_games',
        'dvds_blu_ray',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony');

-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

SELECT 
    AVG(month_sum)
FROM
    (SELECT 
        MONTH(order_purchase_timestamp) AS month_,
            SUM(price) AS month_sum
    FROM
        orders o
    JOIN order_items oi USING (order_id)
    GROUP BY month_) AS monthly_sum;

SELECT 
    AVG(month_sum)
FROM
    (SELECT 
        MONTH(order_purchase_timestamp) AS month_,
            SUM(price) AS month_sum
    FROM
        orders o
    JOIN order_items oi USING (order_id)
    JOIN products USING (product_id)
    JOIN product_category_name_translation USING (product_category_name)
    WHERE
        product_category_name_english IN ('audio' , 'cds_dvds_musicals', 'consoles_games', 'dvds_blu_ray', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony', 'fixed_telephony')
    GROUP BY month_) AS monthly_sum;
    
    
-- In relation to the delivery time

-- What’s the average time between the order being placed and the product being delivered?

SELECT 
    AVG(delivery_time)
FROM
    (SELECT 
        DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) delivery_time
    FROM
        orders) a;



-- How many orders are delivered on time vs orders delivered with a delay?

SELECT 
    SUM(CASE
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) >= 0
        THEN
            1
        ELSE 0
    END) AS ontime_delivery,
    SUM(CASE
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) < 0
        THEN
            1
        ELSE 0
    END) AS delay_delivery
FROM
    orders;

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?

-- average weight of delayed orders
SELECT 
    AVG(product_weight), AVG(dimensional_weight)
FROM
    (SELECT 
        order_id,
            SUM(p.product_weight_g) AS product_weight,
            SUM(product_length_cm * product_height_cm * product_width_cm / 6) AS dimensional_weight
    FROM
        orders
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
    WHERE
        DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 0
    GROUP BY order_id) a;

-- average weight of all orders
SELECT 
    AVG(product_weight), AVG(dimensional_weight)
FROM
    (SELECT 
        order_id,
            SUM(p.product_weight_g) AS product_weight,
            SUM(product_length_cm * product_height_cm * product_width_cm / 6) AS dimensional_weight
    FROM
        orders
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
    GROUP BY order_id) a;

-- average weight of orders delivered in fewer than 5 days
    SELECT 
    AVG(product_weight), AVG(dimensional_weight)
FROM
    (SELECT 
        order_id,
            SUM(p.product_weight_g) AS product_weight,
            SUM(product_length_cm * product_height_cm * product_width_cm / 6) AS dimensional_weight
    FROM
        orders
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
    WHERE
        DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) <= 5
        
    GROUP BY order_id) a;
    
-- average freight cost of all orders
 

SELECT 
    average_freight_cost / (SELECT 
            AVG(dimensional_weight) / 1000
        FROM
            (SELECT 
                order_id,
                    SUM(p.product_weight_g) AS product_weight,
                    SUM(product_length_cm * product_height_cm * product_width_cm / 6) AS dimensional_weight
            FROM
                orders
            JOIN order_items oi USING (order_id)
            JOIN products p USING (product_id)
            GROUP BY order_id) a) aa
FROM
    (SELECT 
        AVG(freight_val) AS average_freight_cost
    FROM
        (SELECT 
        oi.order_id, AVG(oi.freight_value) AS freight_val
    FROM
        order_items oi
    JOIN products p USING (product_id)
    GROUP BY oi.order_id) aaa) aaaa;


-- categorizing review count
SELECT 
    review_score,
    COUNT(*),
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            order_reviews) AS score_percentage
FROM
    order_reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- overview of all orders

   SELECT 
    o.order_id,
    SUM(price) AS total_price,
    AVG(freight_value) AS freight_value,
    SUM(product_weight_g) order_weight,
    SUM(product_length_cm * product_height_cm * product_width_cm / 6) AS dimensional_weight,
    TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date) AS delivery_duration
FROM
    orders o
        JOIN
    order_items oi USING (order_id)
        JOIN
    products p USING (product_id)
GROUP BY order_id;