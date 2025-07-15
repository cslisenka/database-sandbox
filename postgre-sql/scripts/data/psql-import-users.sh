psql -h localhost -U user -d mydb -c "\COPY shop.users(id, email, full_name, created_at, settings) FROM 'users.csv' DELIMITER ',' CSV HEADER;"
