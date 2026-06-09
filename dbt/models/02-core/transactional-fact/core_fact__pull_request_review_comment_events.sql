select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- comment
    safe_cast(nullif(trim(json_value(payload, '$.comment.id')), '') as int64) as comment_id,
    nullif(trim(json_value(payload, '$.comment.node_id')), '') as comment_node_id,                                     -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.comment.pull_request_review_id')), '') as int64) as pull_request_review_id,
    safe_cast(nullif(trim(json_value(payload, '$.comment.in_reply_to_id')), '') as int64) as in_reply_to_id,
    lower(nullif(trim(json_value(payload, '$.comment.commit_id')), '')) as commit_id,
    lower(nullif(trim(json_value(payload, '$.comment.original_commit_id')), '')) as original_commit_id,
    nullif(trim(json_value(payload, '$.comment.body')), '') as comment_body,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.diff_hunk')), '') as comment_diff_hunk,                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.path')), '') as comment__path,                                          -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.comment.position')), '') as int64) as comment_position,
    safe_cast(nullif(trim(json_value(payload, '$.comment.original_position')), '') as int64) as comment_original_position,
    lower(nullif(trim(json_value(payload, '$.comment.subject_type')), '')) as comment_subject_type,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.comment.created_at')), '') as timestamp)) as comment_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.comment.updated_at')), '') as timestamp)) as comment_updated_at,
    nullif(trim(json_value(payload, '$.comment.url')), '') as comment_object_url,                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.html_url')), '') as comment_html_url,                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.pull_request_url')), '') as comment_pull_request_url,                   -- case-sensitive
    nullif(trim(json_value(payload, '$.comment._links.self.href')), '') as comment_self_link_url,                      -- case-sensitive
    nullif(trim(json_value(payload, '$.comment._links.html.href')), '') as comment_html_link_url,                      -- case-sensitive
    nullif(trim(json_value(payload, '$.comment._links.pull_request.href')), '') as comment_pull_request_link_url,      -- case-sensitive
    -- comment.user
    safe_cast(nullif(trim(json_value(payload, '$.comment.user.id')), '') as int64) as comment_user_id,
    nullif(trim(json_value(payload, '$.comment.user.node_id')), '') as comment_user_node_id,                           -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.comment.user.login')), '')) as comment_user_name,
    lower(nullif(trim(json_value(payload, '$.comment.user.type')), '')) as comment_user_type,
    lower(nullif(trim(json_value(payload, '$.comment.user.user_view_type')), '')) as comment_user_user_view_type,
    nullif(trim(json_value(payload, '$.comment.user.gravatar_id')), '') as comment_user_gravatar_id,                   -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.comment.user.site_admin')), '') as bool) as comment_user_site_admin,
    nullif(trim(json_value(payload, '$.comment.user.avatar_url')), '') as comment_user_avatar_url,                      -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.user.url')), '') as comment_user_object_url,                            -- case-sensitive
    nullif(trim(json_value(payload, '$.comment.user.html_url')), '') as comment_user_html_url,                         -- case-sensitive
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
    -- pull_request
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.id')), '') as int64) as pull_request_id,
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.number')), '') as int64) as pull_request_number,
    nullif(trim(json_value(payload, '$.pull_request.url')), '') as pull_request_object_url,                            -- case-sensitive
    -- pull_request.head
    nullif(trim(json_value(payload, '$.pull_request.head.ref')), '') as pull_request_head_ref,                         -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.pull_request.head.sha')), '')) as pull_request_head_sha,
    -- pull_request.head.repo
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.head.repo.id')), '') as int64) as pull_request_head_repo_id,
    nullif(trim(json_value(payload, '$.pull_request.head.repo.name')), '') as pull_request_head_repo_name,             -- case-sensitive
    nullif(trim(json_value(payload, '$.pull_request.head.repo.url')), '') as pull_request_head_repo_object_url,        -- case-sensitive
    -- pull_request.base
    nullif(trim(json_value(payload, '$.pull_request.base.ref')), '') as pull_request_base_ref,                         -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.pull_request.base.sha')), '')) as pull_request_base_sha,
    -- pull_request.base.repo
    safe_cast(nullif(trim(json_value(payload, '$.pull_request.base.repo.id')), '') as int64) as pull_request_base_repo_id,
    nullif(trim(json_value(payload, '$.pull_request.base.repo.name')), '') as pull_request_base_repo_name,             -- case-sensitive
    nullif(trim(json_value(payload, '$.pull_request.base.repo.url')), '') as pull_request_base_repo_object_url,        -- case-sensitive
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'pull_request_review_comment_event'
