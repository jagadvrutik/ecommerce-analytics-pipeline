{% macro get_valid_order_statuses() %}
    {{ return(['completed', 'shipped', 'cancelled', 'returned', 'pending']) }}
{% endmacro %}