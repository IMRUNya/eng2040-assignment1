WITH items AS (
    SELECT order_id,
           COUNT(*) AS n_item_rows,
           COUNT(DISTINCT product_id) AS n_products,
           COUNT(DISTINCT seller_id) AS n_sellers,
           SUM(price) AS items_price_raw,
           SUM(freight_value) AS items_freight_raw
    FROM order_items
    GROUP BY order_id
),
payments AS (
    SELECT order_id,
           COUNT(*) AS n_payment_rows,
           COUNT(payment_value) AS n_payment_values,
           SUM(payment_value) AS payment_raw_centavos,
           SUM(ABS(payment_value)) AS payment_abs_centavos
    FROM order_payments
    GROUP BY order_id
),
reviews AS (
    SELECT order_id,
           COUNT(*) AS n_review_rows
    FROM order_reviews
    GROUP BY order_id
)
SELECT o.order_id,
       o.customer_id,
       c.customer_id IS NOT NULL AS customer_found,
       c.customer_unique_id,
       c.customer_zip_code_prefix,
       c.customer_city,
       c.customer_state,
       o.order_status,
       o.order_purchase_timestamp,
       o.order_approved_at,
       o.order_delivered_carrier_date,
       o.order_delivered_customer_date,
       o.order_estimated_delivery_date,
       COALESCE(i.n_item_rows, 0) AS n_item_rows,
       COALESCE(i.n_products, 0) AS n_products,
       COALESCE(i.n_sellers, 0) AS n_sellers,
       i.items_price_raw,
       i.items_freight_raw,
       COALESCE(p.n_payment_rows, 0) AS n_payment_rows,
       COALESCE(p.n_payment_values, 0) AS n_payment_values,
       p.payment_raw_centavos,
       p.payment_abs_centavos,
       COALESCE(r.n_review_rows, 0) AS n_review_rows
FROM orders AS o
LEFT JOIN customers AS c ON c.customer_id = o.customer_id
LEFT JOIN items AS i ON i.order_id = o.order_id
LEFT JOIN payments AS p ON p.order_id = o.order_id
LEFT JOIN reviews AS r ON r.order_id = o.order_id
ORDER BY o.order_id;
