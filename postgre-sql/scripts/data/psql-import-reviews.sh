psql -h localhost -U user -d mydb -c "\COPY shop.reviews(id, user_id, product_id, rating, comment, created_at) FROM 'reviews.csv' DELIMITER ',' CSV HEADER;"
