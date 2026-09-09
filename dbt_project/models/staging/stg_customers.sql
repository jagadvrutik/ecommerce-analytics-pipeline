with source as (
    select * from {{ ref('customers') }}
),

renamed as (
    select
        customer_id,
        customer_name,
        email,
        region,
        segment,
        signup_date::date as signup_date
    from source
)

select * from renamed