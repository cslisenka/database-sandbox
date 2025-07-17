SHOW default_transaction_isolation;

-- Postgre SQL is MVCC - milti version concurrency control, stores all versions (and transaction work with the snapshot of data)

-- non-repeatable reads
-- we can't see any changes including updates and inserts of new rows)
-- but if modify same data, but both transactions will succeed (no full protection from the concurrent writes)
begin isolation level repeatable read;

-- serializable
-- we can't see any changes including updates and inserts of new rows)
-- second transaction fails in case of concurrent updates! we have full protection from the concurrent writes
-- no blocking, but conflict is derected and transaction rolls back
begin isolation level serializable;
-- reading one record (observe non-repeatable reads)
select * from shop.users
where id = '1481afad-6c3c-4015-bc6e-e85ad425d031'

-- reading multiple records (observe phantom inserts)
select count(*) from shop.users;
select * from shop.users;

-- try modify the data (this query fails in case we have serialisable level)
update shop.users set full_name = 'Changed 2'
where id = '1481afad-6c3c-4015-bc6e-e85ad425d031';
commit;

-- other transaction (modify)
begin;
update shop.users set full_name = 'Changed 2'
where id = '1481afad-6c3c-4015-bc6e-e85ad425d031';
commit;

begin;
insert into shop.users (email, full_name)
values ('test7@test.com', 'Test Testovich');
commit;

rollback;