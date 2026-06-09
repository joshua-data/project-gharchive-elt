select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- comment
    safe_cast(nullif(trim(json_value(payload, '$.comment.id')), '') as int64) as comment_id,
    nullif(trim(json_value(payload, '$.comment.node_id')), '') as comment_node_id,   -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.comment.commit_id')), '')) as commit_id,
    nullif(trim(json_value(payload, '$.comment.body')), '') as comment_body,         -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.path')), '') as comment__path,        -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.comment.line')), '') as int64) as comment_line,
    safe_cast(nullif(trim(json_value(payload, '$.comment.position')), '') as int64) as comment_position,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.comment.created_at')), '') as timestamp)) as comment_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.comment.updated_at')), '') as timestamp)) as comment_updated_at,
    nullif(trim(json_value(payload, '$.comment.url')), '') as comment_object_url,    -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.html_url')), '') as comment_html_url, -- case-sensitive
    -- comment.reactions
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions.total_count')), '') as int64) as reactions_total_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions."+1"')), '') as int64) as reactions_plus_one_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions."-1"')), '') as int64) as reactions_minus_one_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions.laugh')), '') as int64) as reactions_laugh_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions.confused')), '') as int64) as reactions_confused_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions.heart')), '') as int64) as reactions_heart_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions.hooray')), '') as int64) as reactions_hooray_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions.rocket')), '') as int64) as reactions_rocket_count,
    safe_cast(nullif(trim(json_value(payload, '$.comment.reactions.eyes')), '') as int64) as reactions_eyes_count,
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'commit_comment_event'
