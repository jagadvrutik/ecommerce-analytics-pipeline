with customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        customer_id,
        customer_name,
        region,
        segment,
        signup_date,
        total_orders,
        lifetime_spend,
        avg_order_value,
        first_order_date,
        most_recent_order_date,
        datediff('day', most_recent_order_date, current_date()) as days_since_last_order,
        case
            when total_orders = 0 then 'Never Purchased'
            when datediff('day', most_recent_order_date, current_date()) <= 90 then 'Active'
            when datediff('day', most_recent_order_date, current_date()) <= 180 then 'At Risk'
            else 'Churned'
        end as customer_lifecycle_stage
    from customers
)

select * from final