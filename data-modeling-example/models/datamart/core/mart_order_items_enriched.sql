with order_amounts as (
    select
        order_id,
        amount,
        avg(amount) over () as mean_order_amount
    from {{ ref('fct_sales') }}
    where source_system = 'system1'
)

select
    oi.order_item_id,
    oi.order_id,
    oi.customer_id,
    oi.product_id,
    oi.product_name,
    oi.category,
    oi.quantity,
    oi.line_total,
    oi.order_date,
    oa.amount                              as order_amount,
    oa.mean_order_amount,
    oa.amount > oa.mean_order_amount       as is_high_value_order
from {{ ref('fct_order_items') }} oi
inner join order_amounts oa
    on oi.order_id::varchar = oa.order_id
