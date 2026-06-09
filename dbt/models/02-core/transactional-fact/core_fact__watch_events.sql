select
    * except (payload),
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'watch_event'
