select
    org_id,
    created_date as date,
    count(1) as events_count,
    1 as active_days,
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and org_id is not null
    and event_name is not null
group by
    all
