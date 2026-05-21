{{ config(materialized='view', schema='semantic') }}

select date_key as date_day
from {{ ref('t_dim_date') }}
