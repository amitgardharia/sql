create table emp
(
  month,
  emp_id,
  email_id,
  emp_type,
  revoke_access
) 
as
select date'2018-01-01', 1, '',           'temp', date'2018-12-31' from dual
union all
select date'2018-02-01', 1, 'a@test.com', 'temp', date'2018-12-31' from dual
union all
select date'2018-03-01', 1, 'a@test.com', 'temp', date'2018-12-31' from dual
union all
select date'2018-04-01', 1, '',           'temp', date'2018-04-30' from dual
union all
select date'2018-07-01', 1, 'a@test.com', 'full', date'2018-12-31' from dual
union all
select date'2018-08-01', 1, 'a@test.com', 'full', date'2018-12-31' from dual
union all
select date'2018-09-01', 1, 'a@test.com', 'full', date'2018-12-31' from dual

union all
select date'2018-01-01', 2, '',           'temp', date'2018-12-31' from dual
union all
select date'2018-02-01', 2, 'a@test.com', 'temp', date'2018-12-31' from dual
union all
select date'2018-03-01', 2, 'a@test.com', 'temp', date'2018-04-30' from dual
union all
select date'2018-04-01', 2, 'a@test.com', 'temp', date'2018-04-30' from dual
union all
select date'2018-07-01', 2, 'a@test.com', 'full', date'2018-07-31' from dual
union all
select date'2018-09-01', 2, 'a@test.com', 'full', date'2018-12-31' from dual

