psql  --host=127.0.0.1 --username=superset -d superset -f create_cases.sql 
psql  --host=127.0.0.1 --username=superset -d superset -f create_mv_cases_cumsum_all.sql
