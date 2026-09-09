{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='sync_all_columns'
    )
}}

with orders as (
    select * from {{ ref('int_orders_enriched') }}
)

select
    order_id,
    customer_id,
    product_id,
    quantity,
    unit_price,
    total_amount,
    unit_cost,
    total_cost,
    margin_pct,
    payment_method,
    order_status,
    order_date,
    shipping_city,
    shipping_country
from orders
where order_status in ({{ "'" ~ get_valid_order_statuses() | join("', '") ~ "'" }})


{% if is_incremental() %}
    and order_date > (select coalesce(max(order_date), '1900-01-01') from {{ this }})
{% endif %}