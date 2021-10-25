{#
    These macros control how incremental models are updated in Airbyte's normalization step
    - get_max_normalized_cursor retrieve the value of the last normalized data
    - incremental_clause controls the predicate to filter on new data to process incrementally
#}

{% macro get_max_normalized_cursor(col_emitted_at) %}
{% if execute and is_incremental() %}
 {% if env_var('INCREMENTAL_CURSOR', 'UNSET') == 'UNSET' %}
     {% set query %}
        select coalesce(max({{ col_emitted_at }}), cast('1970-01-01 00:00:00' as {{ type_timestamp_with_timezone() }})) from {{ this }}
     {% endset %}
     {% set max_cursor = run_query(query).columns[0][0] %}
     {% do return(max_cursor) %}
 {% else %}
    {% do return(env_var('INCREMENTAL_CURSOR')) %}
 {% endif %}
{% endif %}
{% endmacro %}

{%- macro incremental_clause(col_emitted_at) -%}
{% if is_incremental() %}
and {{ col_emitted_at }} >= cast('{{ get_max_normalized_cursor(col_emitted_at) }}' as {{ type_timestamp_with_timezone() }})
{% endif %}
{%- endmacro -%}