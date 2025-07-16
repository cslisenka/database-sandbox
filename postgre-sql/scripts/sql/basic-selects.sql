-- filter by JSON
select * from shop.users
where (settings ->> 'subscribe_to_newsletter')::boolean = true

-- select field from json
select id, settings ->> 'subscribe_to_newsletter' from shop.users

select * from shop.orders
where status in ('paid', 'shipped')

-- sum of orders per user ordered by max
select user_id, count(*) as orders_count
from shop.orders
group by user_id
order by orders_count desc

-- average raging per every product
select product_id, avg(rating) as average_rating
from shop.reviews
group by product_id
order by average_rating desc

-- average raging per every product + product name and description
select p.name, p.category, average_rating
from shop.products as p
join (
	select product_id, avg(rating) as average_rating
	from shop.reviews
	group by product_id
) as avg_rating
on p.id = avg_rating.product_id

-- TODO all types of joins


-- window functinos example
select *,
	avg(total) over by_user as avg, -- avg all rows before and including current
	sum(total) over by_user as sum, -- sum all rows before and including current
	rank() over by_user as rank,
	total - lead(total) over by_user as diff_to_next_order
from shop.orders where status in ('paid', 'shipped')
window by_user as (partition by user_id order by total desc)

-- last 3 orders of each user
select *
from (
	select *, row_number() over (partition by user_id order by created_at desc) as rn
	from shop.orders
)
where rn <= 3

-- products with no reviews
select p.*, r.*
from shop.products as p
left join shop.reviews r on r.product_id = p.id
where r.id is null

-- products with reviews count
select p.*, r.cnt as review_count
from shop.products as p
left join (
	select product_id, count(*) as cnt
	from shop.reviews
	group by product_id
) r on p.id = r.product_id

-- users who made orders with total amount > 1000, but who didn't make any order
select user_id, sum(total) as total_amount
from shop.orders
group by user_id

-- get review and order count + total per user
explain analyze
select u.*, o.order_count, o.orders_total, r.review_count
from shop.users u
left join (
	select user_id, count(*) as order_count, sum(total) as orders_total
	from shop.orders
	group by user_id
) o on u.id = o.user_id
left join (
	select user_id, count(*) as review_count
	from shop.reviews
	group by user_id
) r on r.user_id = u.id

-- products with at least 5 orders
select p.*, o.review_count
from shop.products p
left join (
	select product_id, count(*) as review_count
	from shop.reviews
	group by product_id
) o on o.product_id = p.id
where o.review_count >= 5

-- users who ordered totally > 3000$
select user_id, sum(total) as total
from shop.orders
group by user_id
having sum(total) > 2000

-- top 3 mostly sold products
select product_id, sum(quantity) as s
from shop.order_items
group by product_id
order by s desc
limit 10

SELECT *
FROM shop.audit_log
WHERE entity = 'orders'
  AND created_at >= NOW() - INTERVAL '30 days';


-- explain
explain
select *
from shop.orders
where user_id = 'b50b87cc-6542-4a6d-8462-fd2cb3051c7e'


-- indices
CREATE INDEX idx_reviews_user_id
ON shop.reviews (user_id);

SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'shop';

-- disable scan, to force searching by index
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT * FROM shop.reviews WHERE user_id = 'b50b87cc-6542-4a6d-8462-fd2cb3051c7e';
SET enable_seqscan = ON;

explain analyze
select *
from shop.reviews
where user_id = 'b50b87cc-6542-4a6d-8462-fd2cb3051c7e'


explain analyze
select *
from shop.reviews
where product_id = 'eab58d4d-4a10-4591-884b-d122f17f27dc'
