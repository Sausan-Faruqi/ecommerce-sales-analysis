-- Check number of customers
SELECT COUNT(*) AS total_customers
FROM customers;


-- Check number of orders
SELECT COUNT(*) AS total_orders
FROM orders;


-- Check order statuses
SELECT order_status, COUNT(*) AS count
FROM orders
GROUP BY order_status
ORDER BY count DESC;


-- Check missing product categories
SELECT COUNT(*) AS missing_categories
FROM products
WHERE product_category_name IS NULL;


-- Check for invalid prices
SELECT *
FROM order_items
WHERE price <= 0;


-- Check missing delivery dates
SELECT COUNT(*) AS missing_delivery_dates
FROM orders
WHERE order_delivered_customer_date IS NULL;