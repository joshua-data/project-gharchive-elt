select
    * except (payload),
    nullif(trim(json_value(payload, '$.ref')), '') as ref,           -- case-sensitive
    nullif(trim(json_value(payload, '$.full_ref')), '') as full_ref, -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.ref_type')), '')) as ref_type,
    lower(nullif(trim(json_value(payload, '$.pusher_type')), '')) as pusher_type,
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'delete_event'
