with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('int_orders_enriched') }}
),

customer_order_stats as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        sum(total_amount) as lifetime_spend,
        avg(total_amount) as avg_order_value,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date
    from orders
    group by customer_id
),

final as (
    select
        customers.customer_id,
        customers.customer_name,
        customers.email,
        customers.region,
        customers.segment,
        customers.signup_date,
        coalesce(stats.total_orders, 0)          as total_orders,
        coalesce(stats.lifetime_spend, 0)        as lifetime_spend,
        stats.avg_order_value,
        stats.first_order_date,
        stats.most_recent_order_date
    from customers
    left join customer_order_stats as stats
        on customers.customer_id = stats.customer_id
)

select * from final