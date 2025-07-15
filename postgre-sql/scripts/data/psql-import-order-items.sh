psql -h localhost -U user -d mydb -c "\COPY shop.order_items(order_id, product_id, quantity, unit_price) FROM 'order_items.csv' DELIMITER ',' CSV HEADER;"
