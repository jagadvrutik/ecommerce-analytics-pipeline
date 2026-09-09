with orders as (
    select * from {{ ref('fct_orders') }}
),

daily as (
    select
        date_trunc('day', order_date)::date as order_day,
        count(distinct order_id)            as total_orders,
        sum(total_amount)                   as total_revenue,
        sum(total_cost)                     as total_cost,
        sum(total_amount) - sum(total_cost) as total_profit,
        {{ calculate_margin_pct('sum(total_amount)', 'sum(total_cost)') }} as overall_margin_pct,
        count(distinct customer_id)         as unique_customers
    from orders
    group by 1
)

select * from daily
order by order_day