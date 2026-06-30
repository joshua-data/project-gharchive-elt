{% macro unify_events(shared_columns, branches) %}

    {% for branch in branches %}
        select
            {% for col in shared_columns %} {{ col }}, {% endfor %}
            '{{ branch.event_name }}' as event_name,
            {% for col in branch.get('extra_columns', []) %} {{ col }}, {% endfor %}
        from
            {{ ref(branch.table) }}
        {% if not loop.last %} full outer union all by name {% endif %}
    {% endfor %}

{% endmacro %}
