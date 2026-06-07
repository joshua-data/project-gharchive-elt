select
    id as event_id,
    lower(regexp_replace(nullif(trim(type), ''), r'([a-z])([A-Z])', r'\1_\2')) as event_name,

    dt as created_date,
    datetime(safe_cast(created_at as timestamp)) as created_at,
    date(safe_cast(ingested_at as timestamp)) as ingested_date,
    datetime(safe_cast(ingested_at as timestamp)) as ingested_at,

    safe_cast(nullif(trim(json_value(actor, '$.id')), '') as int64) as user_id,
    lower(nullif(trim(json_value(actor, '$.login')), '')) as user_name,
    nullif(trim(json_value(actor, '$.display_login')), '') as user_display_name, -- case-sensitive
    -- actor.gravatar_id (deprecated)
    nullif(trim(json_value(actor, '$.url')), '') as user_object_url,             -- case-sensitive
    nullif(trim(json_value(actor, '$.avatar_url')), '') as user_image_url,       -- case-sensitive

    safe_cast(nullif(trim(json_value(repo, '$.id')), '') as int64) as repo_id,
    lower(nullif(trim(json_value(repo, '$.name')), '')) as repo_name,
    nullif(trim(json_value(repo, '$.url')), '') as repo_object_url,              -- case-sensitive

    safe_cast(nullif(trim(json_value(org, '$.id')), '') as int64) as org_id,
    lower(nullif(trim(json_value(org, '$.login')), '')) as org_name,
    -- org.gravatar_id (deprecated)
    nullif(trim(json_value(org, '$.url')), '') as org_object_url,                -- case-sensitive
    nullif(trim(json_value(org, '$.avatar_url')), '') as org_image_url,          -- case-sensitive

    safe.parse_json(payload) as payload,
    public as is_public,
from
    {{ source('gharchive', 'events') }}
where true
    and {{ batch_filter(date_col='dt') }}
qualify
    row_number() over (partition by id order by ingested_at desc) = 1