-- select for update

begin;

-- regular select which does not block
select * from shop.users
where id = 'eca393ae-3e7a-413e-b72a-1dc54dc3a8d1'

-- blocks for reads and writes
select * from shop.users
where id = 'eca393ae-3e7a-413e-b72a-1dc54dc3a8d1'
for update;

-- select for update which fails but not waits
select * from shop.users
where id = 'eca393ae-3e7a-413e-b72a-1dc54dc3a8d1'
for update nowait;

-- blocks for writes, does not block for reads
select * from shop.users
where id = 'eca393ae-3e7a-413e-b72a-1dc54dc3a8d1'
for share;

-- update
update shop.users set full_name = 'Changed!'
where id = 'eca393ae-3e7a-413e-b72a-1dc54dc3a8d1';


commit;