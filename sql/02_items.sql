SELECT order_id,
       order_item_id,
       product_id,
       seller_id,
       price,
       freight_value
FROM order_items
ORDER BY order_id, order_item_id;
