with source as (
    select * from {{ ref('products') }}
),

renamed as (
    select
        product_id,
        product_name,
        category,
        brand,
        unit_cost::number(10,2) as unit_cost
    from source
)

select * from renamed