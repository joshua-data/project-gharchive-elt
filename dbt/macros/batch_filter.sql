{% macro batch_filter(date_col='dt', start_date=none, end_date=none, interval='day') %}

    {% if start_date and end_date %}
        {% set sdt = start_date | string %}
        {% set edt = end_date   | string %}
    {% else %}
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
            {{ exceptions.raise_compiler_error("batch_filter: no valid date parameters provided.") }}
        {% endif %}
    {% endif %}

    {{ date_col }} between date_trunc(date '{{ sdt }}', {{ interval }}) and date '{{ edt }}'

{% endmacro %}

{% macro reverse_batch_filter(date_col='dt', start_date=none, interval='day') %}

    {% if start_date %}
        {% set sdt = start_date | string %}
    {% else %}
        {% set batch_start_date = (var('batch_start_date', '') or '') | string | trim %}
        {% set batch_date       = (var('batch_date',       '') or '') | string | trim %}
        {% if batch_start_date %}
            {% set sdt = batch_start_date %}
        {% elif batch_date %}
            {% set sdt = (modules.datetime.datetime.strptime(batch_date, '%Y-%m-%d').date() - modules.datetime.timedelta(days=1)) | string %}
        {% else %}
            {{ exceptions.raise_compiler_error("batch_filter: no valid date parameters provided.") }}
        {% endif %}
    {% endif %}

    {{ date_col }} < date_trunc(date '{{ sdt }}', {{ interval }})

{% endmacro %}
