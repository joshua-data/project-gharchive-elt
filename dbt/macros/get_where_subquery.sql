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

    {% set batch_start_date = (var('batch_start_date', '') or '') | string | trim %}
    {% set batch_end_date   = (var('batch_end_date',   '') or '') | string | trim %}
    {% set batch_date       = (var('batch_date',       '') or '') | string | trim %}

    {% if batch_start_date and batch_end_date %}
        {% set sdt = batch_start_date %}
        {% set edt = batch_end_date %}
    {% elif batch_date %}
        {% set sdt = (modules.datetime.datetime.strptime(batch_date, '%Y-%m-%d').date() - modules.datetime.timedelta(days=1)) | string %}
        {% set edt = batch_date %}
    {% else %}
        {{ exceptions.raise_compiler_error("replace_batch_dates: no valid date parameters provided.") }}
    {% endif %}

    {% set result = where_string
        | replace("__batch_start_date__", "date '" ~ sdt ~ "'")
        | replace("__batch_end_date__",   "date '" ~ edt ~ "'") %}
    {{ return(result) }}

{% endmacro %}
