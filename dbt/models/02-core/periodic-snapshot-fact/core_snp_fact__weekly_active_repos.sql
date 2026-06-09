{% set interval = 'week(sunday)' %}

select
    repo_id,
    date_trunc(date, {{ interval }}) as date,
    sum(events_count) as events_count,
    sum(active_days) as active_days,
from
    {{ ref('core_snp_fact__daily_active_repos') }}
where true
    and {{ batch_filter(date_col='date', interval=interval) }}
group by
    all
