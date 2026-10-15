SELECT 'orders -> customers' AS relationship,
       (SELECT COUNT(*) FROM orders WHERE customer_id NOT IN (SELECT customer_id FROM customers)) AS unmatched_rows
UNION ALL SELECT 'customers -> orders',
       (SELECT COUNT(*) FROM customers WHERE customer_id NOT IN (SELECT customer_id FROM orders))
UNION ALL SELECT 'order_items -> orders',
       (SELECT COUNT(*) FROM order_items WHERE order_id NOT IN (SELECT order_id FROM orders))
UNION ALL SELECT 'order_items -> products',
       (SELECT COUNT(*) FROM order_items WHERE product_id NOT IN (SELECT product_id FROM products))
UNION ALL SELECT 'order_items -> sellers',
       (SELECT COUNT(*) FROM order_items WHERE seller_id NOT IN (SELECT seller_id FROM sellers))
UNION ALL SELECT 'order_payments -> orders',
       (SELECT COUNT(*) FROM order_payments WHERE order_id NOT IN (SELECT order_id FROM orders))
UNION ALL SELECT 'order_reviews -> orders',
       (SELECT COUNT(*) FROM order_reviews WHERE order_id NOT IN (SELECT order_id FROM orders))
UNION ALL SELECT 'orders without items',
       (SELECT COUNT(*) FROM orders WHERE order_id NOT IN (SELECT order_id FROM order_items))
UNION ALL SELECT 'orders without payments',
       (SELECT COUNT(*) FROM orders WHERE order_id NOT IN (SELECT order_id FROM order_payments))
UNION ALL SELECT 'orders without reviews',
       (SELECT COUNT(*) FROM orders WHERE order_id NOT IN (SELECT order_id FROM order_reviews));
