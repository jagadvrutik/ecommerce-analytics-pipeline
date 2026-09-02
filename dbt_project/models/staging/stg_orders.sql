with source as (
    select * from {{ source('raw_ecommerce', 'raw_orders') }}
),

renamed as (
    select
        order_id,
        raw_payload:customer_id::number       as customer_id,
        raw_payload:product_id::number         as product_id,
        raw_payload:product_category::string   as product_category,
        raw_payload:quantity::number           as quantity,
        raw_payload:unit_price::number(10,2)   as unit_price,
        raw_payload:total_amount::number(10,2) as total_amount,
        raw_payload:payment_method::string     as payment_method,
        raw_payload:order_status::string       as order_status,
        raw_payload:order_date::timestamp_ntz  as order_date,
        raw_payload:shipping_city::string      as shipping_city,
        raw_payload:shipping_country::string   as shipping_country,
        raw_payload:created_at::timestamp_ntz  as source_created_at,
        loaded_at,
        _source_page
    from source
)

select * from renamed