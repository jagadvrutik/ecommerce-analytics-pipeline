{% macro calculate_margin_pct(revenue_column, cost_column) %}
    case
        when {{ revenue_column }} = 0 or {{ revenue_column }} is null then null
        else round((({{ revenue_column }} - {{ cost_column }}) / {{ revenue_column }}) * 100, 2)
    end
{% endmacro %}