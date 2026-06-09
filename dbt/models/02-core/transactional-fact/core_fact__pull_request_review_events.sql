select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- review
    safe_cast(nullif(trim(json_value(payload, '$.review.id')), '') as int64) as review_id,
    nullif(trim(json_value(payload, '$.review.node_id')), '') as review_node_id,                                     -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.review.state')), '')) as review_state,
    lower(nullif(trim(json_value(payload, '$.review.commit_id')), '')) as review_commit_id,
    nullif(trim(json_value(payload, '$.review.body')), '') as review_body,                                           -- case-sensitive
    datetime(safe_cast(nullif(trim(json_value(payload, '$.review.submitted_at')), '') as timestamp)) as review_submitted_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.review.updated_at')), '') as timestamp)) as review_updated_at,
    nullif(trim(json_value(payload, '$.review.html_url')), '') as review_html_url,                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.review.pull_request_url')), '') as review_pull_request_url,                   -- case-sensitive
    nullif(trim(json_value(payload, '$.review._links.html.href')), '') as review_html_link_url,                      -- case-sensitive
    nullif(trim(json_value(payload, '$.review._links.pull_request.href')), '') as review_pull_request_link_url,      -- case-sensitive
    -- review.user
    safe_cast(nullif(trim(json_value(payload, '$.review.user.id')), '') as int64) as review_user_id,
    nullif(trim(json_value(payload, '$.review.user.node_id')), '') as review_user_node_id,                           -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.review.user.login')), '')) as review_user_name,
    lower(nullif(trim(json_value(payload, '$.review.user.type')), '')) as review_user_type,
    lower(nullif(trim(json_value(payload, '$.review.user.user_view_type')), '')) as review_user_user_view_type,
    nullif(trim(json_value(payload, '$.review.user.gravatar_id')), '') as review_user_gravatar_id,                   -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.review.user.site_admin')), '') as bool) as review_user_site_admin,
    nullif(trim(json_value(payload, '$.review.user.avatar_url')), '') as review_user_avatar_url,                      -- case-sensitive
    nullif(trim(json_value(payload, '$.review.user.url')), '') as review_user_object_url,                            -- case-sensitive
    nullif(trim(json_value(payload, '$.review.user.html_url')), '') as review_user_html_url,                         -- case-sensitive
    -- pull_request
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.id')), '') as int64) as pull_request_id,
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.number')), '') as int64) as pull_request_number,
    nullif(trim(json_value(payload, '$.pull_request.url')), '') as pull_request_object_url,                          -- case-sensitive
    -- pull_request.head
    nullif(trim(json_value(payload, '$.pull_request.head.ref')), '') as pull_request_head_ref,                       -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.pull_request.head.sha')), '')) as pull_request_head_sha,
    -- pull_request.head.repo
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.head.repo.id')), '') as int64) as pull_request_head_repo_id,
    nullif(trim(json_value(payload, '$.pull_request.head.repo.name')), '') as pull_request_head_repo_name,           -- case-sensitive
    nullif(trim(json_value(payload, '$.pull_request.head.repo.url')), '') as pull_request_head_repo_object_url,      -- case-sensitive
    -- pull_request.base
    nullif(trim(json_value(payload, '$.pull_request.base.ref')), '') as pull_request_base_ref,                       -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.pull_request.base.sha')), '')) as pull_request_base_sha,
    -- pull_request.base.repo
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.base.repo.id')), '') as int64) as pull_request_base_repo_id,
    nullif(trim(json_value(payload, '$.pull_request.base.repo.name')), '') as pull_request_base_repo_name,           -- case-sensitive
    nullif(trim(json_value(payload, '$.pull_request.base.repo.url')), '') as pull_request_base_repo_object_url,      -- case-sensitive
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'pull_request_review_event'
