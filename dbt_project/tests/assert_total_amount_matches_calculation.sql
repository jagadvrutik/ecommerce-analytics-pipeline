-- A singular test: returns rows that FAIL the assertion.
-- dbt considers this test passed only if it returns zero rows.
select
    order_id,
    quantity,
    unit_price,
    total_amount,
    round(quantity * unit_price, 2) as expected_total
from {{ ref('stg_orders') }}
where abs(total_amount - round(quantity * unit_price, 2)) > 0.01