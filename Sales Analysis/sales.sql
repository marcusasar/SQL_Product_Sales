SELECT * FROM product_sales.sales;

USE product_sales;

SELECT 
	COUNT(*)
FROM sales;

SELECT
	COUNT(*)
FROM
	(
		SELECT
			DISTINCT *
		FROM sales
) AS total;

SELECT
	*
FROM sales
LIMIT 10;

ALTER TABLE sales
DROP COLUMN myunknowncolumn;

DESC sales;

ALTER TABLE sales
MODIFY COLUMN product VARCHAR(255),
MODIFY COLUMN `purchase address` VARCHAR(255),
MODIFY COLUMN city VARCHAR(50),
MODIFY COLUMN `price each` DECIMAL(9,2),
MODIFY COLUMN `sales` DECIMAL(9,2),
MODIFY COLUMN `order id` INT,
MODIFY COLUMN `quantity ordered` INT,
MODIFY COLUMN `order date` DATETIME,
MODIFY COLUMN `hour` INT;

ALTER TABLE sales
-- RENAME COLUMN `order id` TO order_id;
RENAME COLUMN `qauntity_ordered` TO quantity_ordered;
-- RENAME COLUMN `price each` TO price_each,
-- RENAME COLUMN `order date` TO order_date,
-- RENAME COLUMN `purchase address` TO purchase_addres,
-- RENAME COLUMN `month` TO `month`;

SELECT
	*
FROM sales
LIMIT 10;

SELECT
	order_id,
    COUNT(*) AS num_of_times
FROM sales
GROUP BY
	order_id
HAVING num_of_times > 4;

SELECT
	DISTINCT(product)
FROM sales
	ORDER BY product ASC;

SELECT
	DISTINCT(city)
FROM sales
	ORDER BY city ASC;
    
DESC sales;

SELECT
	MIN(price_each) AS minimum_price,
    MAX(price_each) AS maximum_price
FROM sales;

SELECT
	MIN(order_date),
    MAX(order_date)
FROM sales;

SELECT
	MIN(MONTHNAME(order_date)),
    MAX(MONTHNAME(order_date))
FROM sales;

SELECT
	MIN(`month`),
    MAX(`month`)
FROM sales;

SELECT
	MIN(`hour`),
    MAX(`hour`),
    AVG(`hour`)
FROM sales;

-- Analysis -- 
SELECT
	*
FROM sales
LIMIT 20;

-- product with the lowest price and product with the highest price --
-- with least price --
-- Least 5 --
WITH product_least_price (products, price_each) AS (
	SELECT
		DISTINCT (product) AS product,
		price_each
	FROM sales
)
SELECT
	*
FROM product_least_price
	ORDER BY price_each ASC
    LIMIT 5;
    
-- product with high price --
-- Top 5 --
WITH product_highest_price (products, price_each) AS (
	SELECT
		DISTINCT (product) AS product,
		price_each
	FROM sales
)
SELECT
	*
FROM product_highest_price
	ORDER BY price_each DESC
    LIMIT 5;
    
SELECT
	*
FROM sales
	LIMIT 5;
    
DESC sales;

-- total quantity ordered by products --
WITH product_quantity_ordered(product, total_quantity) AS
(
	SELECT
		product,
		SUM(quantity_ordered)
	FROM sales
		GROUP BY product
)
SELECT
	*
FROM product_quantity_ordered
ORDER BY total_quantity DESC;

SELECT
	*
FROM sales;

SELECT
	*
FROM sales;

WITH yearly_order (`year`, `total_order`) AS ( 
SELECT
    EXTRACT(YEAR FROM order_date) AS `year`,
	COUNT(*) AS total_order
FROM sales
	GROUP BY `year`
)
SELECT *
FROM yearly_order;

    
SELECT
	MONTH(order_date) AS monthly,
    COUNT(*) AS total_order
FROM sales
WHERE YEAR(order_date) = "2019"
GROUP BY monthly;

WITH yearly_month_order(years, months, total_order) AS
(
	SELECT
		YEAR(order_date) AS years,
        MONTHNAME(order_date) AS months,
        COUNT(order_id) AS total_order
	FROM sales
    GROUP BY years, months
)
SELECT 
	*,
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_order DESC) AS ranking
FROM yearly_month_order;

WITH yearly_month_order(years, months, products, total_order) AS
(
	SELECT
		YEAR(order_date) AS years,
        MONTHNAME(order_date) AS months,
        product,
        COUNT(order_id) AS total_order
	FROM sales
    GROUP BY years, months, product
),
product_ranking AS (
SELECT 
	*,
    DENSE_RANK() OVER(PARTITION BY years, months ORDER BY total_order DESC) AS ranking
FROM yearly_month_order
)
SELECT * FROM product_ranking
WHERE ranking <= 2;

SELECT
	*
FROM sales
LIMIT 5;

WITH daily_order(days, total_order) AS
(
	SELECT
		DAYNAME(order_date) AS days,
        COUNT(order_id) AS total_order
	FROM sales
    GROUP BY days
)
SELECT 
	*
FROM daily_order
ORDER BY total_order DESC;

-- Total number of product quantity ordered daily -- 
WITH date_order_running (`date`, `total_order`) AS (
	SELECT
		DATE(order_date),
		COUNT(*)
	FROM sales
		GROUP BY DATE(order_date)
)
SELECT 
	*,
    SUM(total_order) OVER(ORDER BY `date` ASC) AS running_total
FROM date_order_running
ORDER BY `date` ASC;

SELECT *
FROM sales
LIMIT 5;

WITH yearly_month_order(years, months, total_order) AS
(
	SELECT
		YEAR(order_date) AS years,
        MONTHNAME(order_date) AS months,
        COUNT(order_id) AS total_order
	FROM sales
    GROUP BY years, months
)
SELECT 
	*,
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_order DESC) AS ranking
FROM yearly_month_order;

WITH daily_order(dates, days, products, total_order) AS
(
	SELECT
		DATE(order_date) AS `date`,
        DAYNAME(order_date) AS days,
        product,
        COUNT(*) 
	FROM sales
    GROUP BY `date`, days, product
),
product_ranking AS (
SELECT 
	dates,
    days,
    products,
    total_order,
    DENSE_RANK() OVER(PARTITION BY dates ORDER BY total_order DESC) AS ranking
FROM daily_order
)
SELECT * FROM product_ranking
WHERE dates <= "2019-10-31" AND ranking <= 1;

SELECT
	*
FROM sales
LIMIT 5;

SELECT
	YEAR(order_date) AS `year`,
    SUM(sales) AS total_sales
FROM sales
	GROUP BY `year`;

WITH product_sales (product, total_sales) AS 
(
	SELECT
		product,
        SUM(sales)
	FROM sales
    WHERE YEAR(order_date) = "2020"
    GROUP BY product
)
SELECT 
	*,
    DENSE_RANK() OVER(ORDER BY total_sales DESC) AS ranking
FROM product_sales;

DROP PROCEDURE IF EXISTS product_sales;
DELIMITER $$
CREATE PROCEDURE product_sales (years varchar(5))
		BEGIN
			SELECT
				YEAR(order_date) AS yearly,
				product,
                SUM(quantity_ordered) AS total_qauntity,
				SUM(sales) AS total_sales
			FROM sales
				WHERE YEAR(order_date) = years
				GROUP BY yearly, product
				ORDER BY total_sales DESC;
		END $$
DELIMITER ;

CALL product_sales("2020");



-- DROP PROCEDURE IF EXISTS product_sales;
USE product_sales;

SELECT
	*
FROM sales
LIMIT 10;

SELECT
	4727 * 1700;
    
SELECT
	YEAR(order_date) AS `year`,
	city,
    COUNT(*) AS total_order,
    SUM(sales) AS total_sales
FROM sales
	GROUP BY `year`, city
    HAVING `year` = "2019"
    ORDER BY total_order DESC;
    
WITH orders_by_city (`month`, city, total_order, total_sales)  AS 
(
	SELECT
		MONTH(order_date) AS `months`,
        city,
        COUNT(*),
        SUM(sales)
	FROM
		sales
        GROUP BY
				`months`, city
)
SELECT
	*,
    DENSE_RANK() OVER(PARTITION BY `month`, city ORDER BY total_order DESC) AS ranking
FROM orders_by_city;

-- finding orders that came in from each city during each of the month --
WITH orders_by_city (`month`, city, product, total_order, total_sales)  AS 
(
	SELECT
		MONTH(order_date) AS `months`,
        city,
        product,
        COUNT(*),
        SUM(sales)
	FROM
		sales
        GROUP BY
				`months`, city, product
),
ranking AS
(
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY `month`, city ORDER BY total_sales DESC) AS ranks
	FROM orders_by_city
)
SELECT
	*
FROM ranking
WHERE ranks <= 1;


