psql -h localhost -U user -d mydb -c "\COPY shop.audit_log(entity, entity_id, action, data, created_at) FROM 'audit_log.csv' DELIMITER ',' CSV HEADER;"

