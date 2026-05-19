{{
    config(
        materialized='view'
    )
}}

with monthly_orders as (
    select
        customer_id,
        date_trunc('month', order_date)::date as order_month,
        count(*) as orders_in_month
    from {{ ref('fct_sales') }}
    group by 1, 2
)

select
    customer_id,
    order_month,
    orders_in_month,
    case when orders_in_month > 1 then 1 else 0 end as is_repeat_buyer
from monthly_orders
