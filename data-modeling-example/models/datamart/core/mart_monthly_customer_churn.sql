with monthly_orders as (
    select
        customer_id,
        date_trunc('month', order_date)::date as order_month
    from {{ ref('fct_sales') }}
    group by 1, 2
),

all_months as (
    select distinct date_trunc('month', date_day)::date as month_date
    from {{ ref('util_date_spine') }}
),

customers as (
    select distinct customer_id from {{ ref('fct_sales') }}
),

customer_months as (
    select c.customer_id, m.month_date
    from customers c
    cross join all_months m
),

with_flags as (
    select
        cm.customer_id,
        cm.month_date,
        (mo.order_month is not null)::int      as is_active,
        (mo_prev.order_month is not null)::int as was_active_prev_month
    from customer_months cm
    left join monthly_orders mo
        on cm.customer_id = mo.customer_id
        and cm.month_date = mo.order_month
    left join monthly_orders mo_prev
        on cm.customer_id = mo_prev.customer_id
        and (cm.month_date - interval '1 month')::date = mo_prev.order_month
)

select
    customer_id,
    month_date,
    is_active,
    was_active_prev_month,
    case
        when was_active_prev_month = 1 and is_active = 0 then 1
        else 0
    end as is_churned_this_month
from with_flags
where was_active_prev_month = 1 or is_active = 1
