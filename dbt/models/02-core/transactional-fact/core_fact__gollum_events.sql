select
    e.* except (payload),
    -- pages (repeated nested struct; preserves event_id grain)
    array(
        select as struct
            nullif(trim(json_value(p, '$.page_name')), '') as page_name,    -- case-sensitive
            nullif(trim(json_value(p, '$.title')), '') as title,            -- case-sensitive
            nullif(trim(json_value(p, '$.summary')), '') as summary,        -- case-sensitive
            lower(nullif(trim(json_value(p, '$.action')), '')) as action,
            lower(nullif(trim(json_value(p, '$.sha')), '')) as sha,
            nullif(trim(json_value(p, '$.html_url')), '') as html_url,      -- case-sensitive
        from unnest(json_query_array(e.payload, '$.pages')) p
    ) as pages,
from
    {{ ref('stg_fact__events') }} e
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'gollum_event'
