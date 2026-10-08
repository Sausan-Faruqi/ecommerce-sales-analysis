--Total Delivered Orders--
SELECT COUNT(*) AS total_delivered_orders
FROM orders
WHERE order_status = 'delivered';

--Total Revenue--
SELECT ROUND(SUM(price), 2) AS total_revenue
FROM order_items;

--Average Order Value--
WITH order_totals AS (
    SELECT
        order_id,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;


--Monthly Revenue Trend--
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;


--Top Product Categories By Revenue--
SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;


--Top Categories By Number of Items Sold--
SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY items_sold DESC
LIMIT 10;


--Revenue By State--
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;


--Highest Value Customers--
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    ROUND(SUM(oi.price), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;


--Repeat Customers--
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS repeat_customers
FROM customer_orders
WHERE order_count > 1;


--Payment method analysis--
SELECT
    payment_type,
    COUNT(*) AS transactions,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM payments
GROUP BY payment_type
ORDER BY transactions DESC;

--Installment Behavior--
SELECT
    payment_installments,
    COUNT(*) AS transactions
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;


--Late Deliveries--
SELECT
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;
	  
--Late Delivery Percentage--
SELECT
    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE order_delivered_customer_date >
                  order_estimated_delivery_date
        )
        / COUNT(*),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


--Month Over Month Revenue Growth--
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
),

revenue_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        ((revenue - previous_month_revenue)
        / previous_month_revenue) * 100,
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY month;