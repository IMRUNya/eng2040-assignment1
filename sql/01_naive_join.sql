SELECT COUNT(*) AS joined_rows,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(p.payment_value) AS payment_raw_centavos
FROM orders AS o
LEFT JOIN order_items AS i ON i.order_id = o.order_id
LEFT JOIN order_payments AS p ON p.order_id = o.order_id;
