{{ config(materialized='view') }}

select cast(range_date as date) as date_day
from generate_series(
    date '2000-01-01',
    date '2030-01-01',
    interval '1 day'
) as t(range_date)
