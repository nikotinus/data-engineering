select 
o.city  		
, count(distinct o.order_id) as orders_count
, round(sum(o.sales), 2) as revenue
from public.orders o
group by 
	1
order by 3 desc;

select 
count(1),
count(distinct o.order_id)
from public.orders o ;
--9994 rows from 5009 orders

select
count(12)
, count(distinct o.order_id)
, sum()
, count(distinct r.orderid) b
from public.orders o left join public."returns" r on o.order_id = r.orderid ;

--inner 3226 rows from 296 orders

select
count(1)
, count(distinct o.order_id)
, round(sum(o.sales), 2) as total_sum
, round(sum(o.profit), 2) as lost_profit
from public.orders o 
where o.order_id in (select distinct r.orderid from public."returns" r)