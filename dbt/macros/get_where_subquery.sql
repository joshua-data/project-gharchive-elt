{% macro get_where_subquery(relation) -%}

    {% set where = config.get('where') %}

    {% if where %}

        {% if "__batch_start_date__" in where or "__batch_end_date__" in where %}
            {# replace placeholder strings with actual batch date values #}
            {% set where = replace_batch_dates(where) %}
        {% endif %}
        {% set filtered %}
            (select * from {{ relation }} where {{ where }}) dbt_subquery
        {% endset %}
        {% do return(filtered) %}

    {%- else -%}

        {% do return(relation) %}

    {%- endif -%}

{%- endmacro %}


{% macro replace_batch_dates(where_string) %}

    {% set batch_start_date = (var('batch_start_date', '') or var('batch_date', '')) | string | trim %}
    {% set batch_end_date   = (var('batch_end_date',   '') or var('batch_date', '')) | string | trim %}

    {% if not batch_start_date or not batch_end_date %}
        {{ exceptions.raise_compiler_error("replace_batch_dates: no valid date parameters provided (batch_start_date/batch_end_date or batch_date).") }}
    {% endif %}

    {% set result = where_string
        | replace("__batch_start_date__", "date '" ~ batch_start_date ~ "'")
        | replace("__batch_end_date__",   "date '" ~ batch_end_date   ~ "'") %}
    {{ return(result) }}

{% endmacro %}
