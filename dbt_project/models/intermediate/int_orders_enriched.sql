with orders as (
    select * from {{ ref('stg_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

enriched as (
    select
        orders.order_id,
        orders.customer_id,
        orders.product_id,
        orders.quantity,
        orders.unit_price,
        orders.total_amount,
        products.unit_cost,
        round(orders.quantity * products.unit_cost, 2) as total_cost,
        {{ calculate_margin_pct('orders.total_amount', 'round(orders.quantity * products.unit_cost, 2)') }} as margin_pct,
        orders.payment_method,
        orders.order_status,
        orders.order_date,
        orders.shipping_city,
        orders.shipping_country
    from orders
    left join products
        on orders.product_id = products.product_id
)

select * from enriched