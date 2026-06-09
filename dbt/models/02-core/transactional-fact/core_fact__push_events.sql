select
    * except (payload),
    -- push
    safe_cast(nullif(trim(json_value(payload, '$.push_id')), '') as int64) as push_id,
    nullif(trim(json_value(payload, '$.ref')), '') as ref,         -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.head')), '')) as head,
    lower(nullif(trim(json_value(payload, '$.before')), '')) as before,
    -- repository
    safe_cast(nullif(trim(json_value(payload, '$.repository_id')), '') as int64) as repository_id,
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'push_event'
