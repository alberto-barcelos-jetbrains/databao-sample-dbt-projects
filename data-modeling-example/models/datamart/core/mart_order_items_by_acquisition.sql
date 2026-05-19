{{ config(materialized='view') }}

with

enriched as (
    select * from {{ ref('mart_order_items_enriched') }}
),

sales as (
    select
        order_id,
        referral_code
    from {{ ref('fct_sales') }}
    where source_system = 'system1'
),

final as (
    select
        e.order_item_id,
        e.order_id,
        e.customer_id,
        e.product_id,
        e.product_name,
        e.category,
        e.quantity,
        e.line_total,
        e.order_date,
        e.is_high_value_order,
        s.referral_code,
        case
            when s.referral_code = 'none' then 'organic'
            else 'referral'
        end as acquisition_type
    from enriched e
    inner join sales s
        on e.order_id::varchar = s.order_id
)

select * from final
