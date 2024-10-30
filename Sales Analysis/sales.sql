-- Set the active database to 'product_sales'
USE product_sales;

-- Count the total number of records (orders) in the sales table
SELECT COUNT(*)
FROM sales;

-- Count the total number of distinct records in the sales table
SELECT
	COUNT(*)
FROM
	(
		SELECT
			DISTINCT *
		FROM sales
	) AS total;

-- Retrieve the first 10 records from the sales table
SELECT *
FROM 
	sales
LIMIT 10;

-- Remove the column 'myunknowncolumn' from the sales table
ALTER TABLE sales
DROP COLUMN myunknowncolumn;

-- Display the structure of the 'sales' table, including column names, data types, and other attributes
DESCRIBE sales;

-- Modify the data types and sizes of various columns in the sales table
ALTER TABLE sales
MODIFY COLUMN product VARCHAR(255),              -- Change product column to a VARCHAR of length 255
MODIFY COLUMN `purchase address` VARCHAR(255),   -- Change purchase address column to a VARCHAR of length 255
MODIFY COLUMN city VARCHAR(50),                   -- Change city column to a VARCHAR of length 50
MODIFY COLUMN `price each` DECIMAL(9,2),         -- Change price each column to a DECIMAL with 9 digits total and 2 decimal places
MODIFY COLUMN `sales` DECIMAL(9,2),              -- Change sales column to a DECIMAL with 9 digits total and 2 decimal places
MODIFY COLUMN `order id` INT,                     -- Change order id column to an INT
MODIFY COLUMN `quantity ordered` INT,             -- Change quantity ordered column to an INT
MODIFY COLUMN `order date` DATETIME,              -- Change order date column to a DATETIME
MODIFY COLUMN `hour` INT;                         -- Change hour column to an INT

-- Rename columns in the sales table for consistency and clarity
ALTER TABLE sales
RENAME COLUMN `order id` TO order_id,                -- Rename 'order id' to 'order_id'
RENAME COLUMN `qauntity_ordered` TO quantity_ordered, -- Correct 'qauntity_ordered' to 'quantity_ordered'
RENAME COLUMN `price each` TO price_each,            -- Rename 'price each' to 'price_each'
RENAME COLUMN `order date` TO order_date,            -- Rename 'order date' to 'order_date'
RENAME COLUMN `purchase address` TO purchase_address, -- Correct 'purchase address' to 'purchase_address'
RENAME COLUMN `month` TO `month`;                    -- Rename 'month' to 'month' (no change)

-- Retrieve the first 10 records from the sales table
SELECT
    *
FROM 
	sales
LIMIT 10;

-- Retrieve order IDs and the count of occurrences for each order,
-- filtering to include only those orders that appear more than 4 times
SELECT
    order_id,
    COUNT(*) AS num_of_times
FROM 
	sales
GROUP BY 
	order_id
HAVING 
	COUNT(*) > 4;  -- Only include orders with more than 4 occurrences

-- Retrieve a list of distinct products from the sales table,
-- ordered alphabetically in ascending order
SELECT
    DISTINCT(product)
FROM 
	sales
ORDER BY 
	product ASC;

-- Retrieve a list of distinct cities from the sales table,
-- ordered alphabetically in ascending order
SELECT 
    DISTINCT(city) 
FROM 
    sales 
ORDER BY 
    city ASC;

-- Retrieve the minimum and maximum price of items sold from the sales table
SELECT
	MIN(price_each) AS minimum_price,
    MAX(price_each) AS maximum_price
FROM 
	sales;

-- Retrieve the earliest and latest order dates from the sales table
SELECT
	MIN(order_date),
    MAX(order_date)
FROM 
	sales;


-- Retrieve the names of the earliest and latest months in which orders were placed
SELECT
	MIN(MONTHNAME(order_date)),
    MAX(MONTHNAME(order_date))
FROM 
	sales;

-- Retrieve the earliest and latest months recorded in the sales table
SELECT
	MIN(`month`),
    MAX(`month`)
FROM 
	sales;

-- Retrieve the minimum, maximum and average hours recorded in the sales table
SELECT
	MIN(`hour`),
    MAX(`hour`),
    AVG(`hour`)
FROM 
	sales;

------------------------------------------- ANALYSIS -------------------------------------------------


-- CTE to retrieve distinct products and their prices,
-- then select the 5 products with the lowest prices the sales table
WITH product_least_price (products, price_each) AS (
	SELECT
		DISTINCT (product) AS product,
		price_each
	FROM 
		sales
)
SELECT
	*
FROM p
	roduct_least_price
ORDER BY 
	price_each ASC
LIMIT 5;
    
-- CTE to retrieve distinct products and their prices,
-- then select the 5 products with the highest prices
-- Top 5 --
WITH product_highest_price (products, price_each) AS (
	SELECT
		DISTINCT (product) AS product,
		price_each
	FROM 
		sales
)
SELECT
	*
FROM 
	product_highest_price
ORDER BY 
	price_each DESC
LIMIT 5;
    
-- CTE to calculate the total quantity ordered for each product from the sales table, 
-- then select all products ordered by total quantity in descending order
WITH product_quantity_ordered(product, total_quantity) AS
(
	SELECT
		product,
		SUM(quantity_ordered)
	FROM 
		sales
	GROUP BY 
		product
)
SELECT
	*
FROM 
	product_quantity_ordered
ORDER BY 
	total_quantity DESC;

-- CTE to calculate the total number of orders for each year from the sales table, 
-- extracting the year from the order date and counting the orders
WITH yearly_order (`year`, `total_order`) AS ( 
    SELECT
        EXTRACT(YEAR FROM order_date) AS `year`,
        COUNT(*) AS total_order
    FROM 
        sales
    GROUP BY 
        `year`
)
SELECT 
	*
FROM 
	yearly_order;


-- Retrieve the total number of orders for each month in the year 2019,
-- grouping the results by month    
SELECT
	MONTH(order_date) AS monthly,
    COUNT(*) AS total_order
FROM 
	sales
WHERE 
	YEAR(order_date) = "2019"
GROUP BY 
	monthly;

-- CTE to calculate the total number of orders for each month in each year from the sales table, 
-- grouping by year and month name
WITH yearly_month_order(years, months, total_order) AS
(
	SELECT
		YEAR(order_date) AS years,
        MONTHNAME(order_date) AS months,
        COUNT(*) AS total_order
	FROM 
		sales
    GROUP BY 
		years, months
)
SELECT 
	*,
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_order DESC) AS ranking
FROM 
	yearly_month_order;

-- CTE to calculate the total number of orders for each product by year and month from the sales table,
-- grouping by year, month, and product
WITH yearly_month_order(years, months, products, total_order) AS
(
	SELECT
		YEAR(order_date) AS years,
        MONTHNAME(order_date) AS months,
        product,
        COUNT(order_id) AS total_order
	FROM 
		sales
    GROUP BY 
		years, months, product
),
product_ranking AS (
	-- Rank products by total orders within each year and month using DENSE_RANK
	SELECT 
		*,
		DENSE_RANK() OVER(PARTITION BY years, months ORDER BY total_order DESC) AS ranking
	FROM 
		yearly_month_order
)
-- Select the top 2 products per month for each year based on total orders
SELECT * 
FROM 
	product_ranking
WHERE 
	ranking <= 2;

-- CTE to calculate the total number of orders for each day of the week from the sales table,
-- grouping by the name of the day
WITH daily_order(days, total_order) AS
(
	SELECT
		DAYNAME(order_date) AS days,
        COUNT(order_id) AS total_order
	FROM 
		sales
    GROUP BY 
		days
)
-- Select all days and their total orders, ordering the results by total orders in descending order
SELECT 
	*
FROM 
	daily_order
ORDER BY 
	total_order DESC;

-- CTE to calculate the total number of orders for each date from the sales table,
-- grouping the results by the date of the order
WITH date_order_running (`date`, `total_order`) AS (
	SELECT
		DATE(order_date),
		COUNT(*)
	FROM 
		sales
	GROUP BY 
		DATE(order_date)
)
-- Select all dates and their total orders, adding a running total of orders 
-- ordered by date in ascending order
SELECT 
	*,
    SUM(total_order) OVER(ORDER BY `date` ASC) AS running_total
FROM 
	date_order_running
ORDER BY 
	`date` ASC;

-- CTE to calculate the total number of orders for each month in each year from the sales table,
-- grouping the results by year and month name
WITH yearly_month_order(years, months, total_order) AS
(
	SELECT
		YEAR(order_date) AS years,
        MONTHNAME(order_date) AS months,
        COUNT(order_id) AS total_order
	FROM 
		sales
    GROUP BY 
		years, months
)
-- Select all year and month combinations along with their total orders,
-- adding a ranking based on total orders within each year
SELECT 
	*,
    DENSE_RANK() OVER(PARTITION BY years ORDER BY total_order DESC) AS ranking
FROM 
	yearly_month_order;

-- CTE to calculate the total number of orders for each product by date and day of the week from the sales table,
-- grouping the results by date, day name, and product
WITH daily_order(dates, days, products, total_order) AS
(
	SELECT
		DATE(order_date) AS `date`,
        DAYNAME(order_date) AS days,
        product,
        COUNT(*) 
	FROM 
		sales
    GROUP BY 
		`date`, days, product
),
product_ranking AS (
	-- Rank products based on total orders for each date using DENSE_RANK
	SELECT 
		dates,
		days,
		products,
		total_order,
		DENSE_RANK() OVER(PARTITION BY dates ORDER BY total_order DESC) AS ranking
	FROM 
		daily_order
)
-- Select the top-ranked product(s) for each date up to October 31, 2019
SELECT 
    * 
FROM 
    product_ranking
WHERE 
    dates <= '2019-10-31' 
    AND ranking <= 1;

-- Retrieve the total sales for each year from the sales table, 
-- grouping the results by year extracted from the order date
SELECT
	YEAR(order_date) AS `year`,
    SUM(sales) AS total_sales
FROM 
	sales
GROUP BY 
	`year`;

-- CTE to calculate total sales for each product in the year 2020,
-- grouping the results by product
WITH product_sales (product, total_sales) AS 
(
	SELECT
		product,
        SUM(sales)
	FROM 
		sales
    WHERE 
		YEAR(order_date) = "2020"
    GROUP BY 
		product
)
-- Select all products and their total sales, adding a ranking based on total sales in descending order
SELECT 
	*,
    DENSE_RANK() OVER(ORDER BY total_sales DESC) AS ranking
FROM 
	product_sales;

-- Drop the existing stored procedure named product_sales if it exists
DROP PROCEDURE IF EXISTS product_sales;


-- Create a stored procedure named product_sales that takes a year as an argument
DELIMITER $$
CREATE PROCEDURE product_sales (years varchar(5))
BEGIN
	-- Select total quantity ordered and total sales for each product for the specified year,
    -- grouping the results by year and product
	SELECT
		YEAR(order_date) AS yearly,
		product,
        SUM(quantity_ordered) AS total_qauntity,
		SUM(sales) AS total_sales
	FROM 
		sales
	WHERE 
		YEAR(order_date) = years
	GROUP BY 
		yearly, product
	ORDER BY 
		total_sales DESC;

END $$

DELIMITER ;

-- Call the product_sales procedure to retrieve sales data for the year 2020
CALL product_sales("2020");


-- Retrieve the total number of orders and total sales for each city in the year 2019,
-- grouping the results by year and city   
SELECT
	YEAR(order_date) AS `year`,
	city,
    COUNT(*) AS total_order,
    SUM(sales) AS total_sales
FROM 
	sales
GROUP BY 
	`year`, city
HAVING 
	`year` = "2019" -- Filter results to only include data from the year 2019
ORDER BY 
	total_order DESC; -- Order the results by total orders in descending order

-- CTE to calculate the total number of orders and total sales for each city by month from the sales table,
-- grouping the results by month and city
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
-- Select all data from the CTE and add a ranking for each city based on total orders within each month
SELECT
	*,
    DENSE_RANK() OVER(PARTITION BY `month`, city ORDER BY total_order DESC) AS ranking
FROM 
	orders_by_city;


-- CTE to calculate the total number of orders and total sales for each product in each city by month
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
	-- Rank products based on total sales within each month and city using DENSE_RANK
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY `month`, city ORDER BY total_sales DESC) AS ranks
	FROM 
		orders_by_city
)
-- Select only the top-ranked product(s) for each city and month based on total sales
SELECT
	*
FROM 
	ranking
WHERE 
	ranks <= 1;


