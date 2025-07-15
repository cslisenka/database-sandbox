psql -h localhost -U user -d mydb -c "\COPY shop.orders(id, user_id, status, total, created_at) FROM 'orders.csv' DELIMITER ',' CSV HEADER;"

