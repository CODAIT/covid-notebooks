CREATE MATERIALIZED VIEW cases_cumsum_all
as
select t1.daterep, t1.cases, SUM(t2.cases) as sum
from cases  t1
inner join cases t2 on t1.id >= t2.id
group by t1.id, t1.cases
order by t1.id

