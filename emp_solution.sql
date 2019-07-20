with
  /*
     generate a type 2 dimension with start and end date. a record where
     access has been revoked before the next snapshot period will have the 
     the end date as access revoked date
  */
  w_interval as
  (
    select
      month,
      emp_id,
      email_id,
      emp_type,
      revoke_access,
      month as start_dt,
      case
        when revoke_access < lead(month) over (partition by emp_id order by month)
        then revoke_access
        else coalesce(lead(month) over (partition by emp_id order by month), date'9999-12-31')
      end as end_dt,
--      0 as is_deleted,
      row_number() over (partition by emp_id order by month) as rid
    from
      emp
  ),
  -- identify gaps
  w_interval2 as
  (
    select
      l.rid,
      l.emp_id,
      l.email_id,
      l.emp_type,
      l.revoke_access,
      l.start_dt,
      l.end_dt,
      lead(l.start_dt) over (partition by l.emp_id order by l.rid) as next_start_dt,
--      l.is_deleted,
--      case when l.end_dt != r.start_dt then 1 else 0 end as has_gap
      case 
        when l.end_dt != lead(l.start_dt) over (partition by l.emp_id order by l.rid)
        then 1
        else 0
      end as has_gap
    from 
      w_interval l
--      left join w_interval r on
--        l.emp_id = r.emp_id
--        and l.rid + 1 = r.rid
  ),
  -- insert deleted records
  w_filled_gaps as
  (
    select
      i.emp_id,
      i.email_id,
      i.emp_type,
      i.revoke_access,
      m.is_deleted,
      case
        when m.is_deleted = 1
        then end_dt
        else start_dt
      end as start_dt,
      case
        when m.is_deleted = 1
        then next_start_dt
        else end_dt
      end as end_dt
    from
      w_interval2 i
      join 
        (
          select 1 as has_gap, 0 as is_deleted from dual
          union all
          select 1 as has_gap, 1 as is_deleted from dual
          union all
          select 0 as has_gap, 0 as is_deleted from dual
        ) m on
        i.has_gap = m.has_gap
--    order by
--      i.emp_id,
--      i.start_dt
  ),
  -- recompute row id per emp id
  w_all_rows_with_rid as
  (
    select 
      l.*,
      row_number() over (partition by emp_id order by start_dt) as rid
    from
      w_filled_gaps l
  )
-- merge continuous interval with no changes into 1 single interval  
select
  c.emp_id,
  c.email_id,
  c.emp_type,
  c.revoke_access,
  c.is_deleted,
--  l.start_dt,
--  l.end_dt,
  greatest(coalesce(lag(c.end_dt) over (partition by c.emp_id order by c.start_dt), c.start_dt), c.start_dt) as start_dt,
  coalesce(lead(c.start_dt) over (partition by c.emp_id order by c.start_dt), date'9999-12-31') as end_dt
from
  w_all_rows_with_rid c
  left join w_all_rows_with_rid n on
    c.emp_id = n.emp_id
    and c.rid = n.rid + 1
where
  1=2
  or coalesce(c.emp_type, '-') != coalesce(n.emp_type, '-')
  or coalesce(c.revoke_access, date'1900-01-01') != coalesce(n.revoke_access, date'1900-01-01')
  or coalesce(c.email_id, '-') != coalesce(n.email_id, '-')
  or c.is_deleted != n.is_deleted
order by
  c.emp_id,
  c.start_dt
