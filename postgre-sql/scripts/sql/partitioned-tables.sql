-- partitioned table
-- table is splitted into separate physical partitions
-- helps when we have big data volumes - faster selects if only in one patition, faster deletes if we delete the entire partition
-- can be a separate indices and constraints per partition
-- partitions can be stored on different physical servers

-- primary key and unique work only within partition
CREATE TABLE shop.logs (
    id SERIAL,
    created_at DATE,
    message TEXT
) PARTITION BY RANGE (created_at);

CREATE TABLE shop.logs_2024 PARTITION OF shop.logs
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE shop.logs_2025 PARTITION OF shop.logs
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

INSERT INTO shop.logs (created_at, message) VALUES ('2024-08-01', 'Something in 2024');
INSERT INTO shop.logs (created_at, message) VALUES ('2025-08-01', 'Something in 2025');

-- runs to scans and makes union if we search over the big table
explain analyze
select *
from shop.logs
where created_at > '2025-01-01' -- queries are faster if we specify the partition key