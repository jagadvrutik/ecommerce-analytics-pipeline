with products as (
    select * from {{ ref('stg_products') }}
),

order_stats as (
    select
        product_id,
        count(distinct order_id)  as total_times_ordered,
        sum(quantity)             as total_units_sold,
        avg(margin_pct)           as avg_margin_pct
    from {{ ref('int_orders_enriched') }}
    group by product_id
),

final as (
    select
        products.product_id,
        products.product_name,
        products.category,
        products.brand,
        products.unit_cost,
        coalesce(order_stats.total_times_ordered, 0) as total_times_ordered,
        coalesce(order_stats.total_units_sold, 0)     as total_units_sold,
        order_stats.avg_margin_pct
    from products
    left join order_stats
        on products.product_id = order_stats.product_id
)

select * from final