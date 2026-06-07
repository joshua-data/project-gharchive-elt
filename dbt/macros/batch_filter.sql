{% macro batch_filter(date_col='dt', start_date=none, end_date=none) %}

    {% if start_date and end_date %}

        {{ date_col }} between date '{{ start_date }}' and date '{{ end_date }}'

    {% else %}

        {% set batch_start_date = (var('batch_start_date', '') or '') | string | trim %}
        {% set batch_end_date = (var('batch_end_date',   '') or '') | string | trim %}
        {% set batch_date  = (var('batch_date',       '') or '') | string | trim %}
        
        {% if batch_start_date and batch_end_date %}
            {{ date_col }} between date '{{ batch_start_date }}' and date '{{ batch_end_date }}'
        {% elif batch_date %}
            {% set batch_end_date = modules.datetime.datetime.strptime(batch_date, '%Y-%m-%d').date() %}
            {% set batch_start_date = batch_end_date - modules.datetime.timedelta(days=1) %}
            {{ date_col }} between date '{{ batch_start_date }}' and date '{{ batch_end_date }}'
        {% else %}
            {{ exceptions.raise_compiler_error("batch_filter: no valid date parameters provided.") }}
        {% endif %}

    {% endif %}

{% endmacro %}
