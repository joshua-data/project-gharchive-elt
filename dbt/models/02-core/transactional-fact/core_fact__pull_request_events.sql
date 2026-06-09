select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
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
    -- label (present on action in ('labeled', 'unlabeled'))
    safe_cast(nullif(trim(json_value(payload, '$.label.id')), '') as int64) as label_id,
    nullif(trim(json_value(payload, '$.label.node_id')), '') as label_node_id,                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.label.name')), '') as label_name,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.label.color')), '') as label_color,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.label.description')), '') as label_description,                               -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.label.default')), '') as bool) as label_default,
    nullif(trim(json_value(payload, '$.label.url')), '') as label_object_url,                                        -- case-sensitive
    -- labels (present on action in ('labeled', 'unlabeled'))
    json_query_array(payload, '$.labels') as labels,
    -- assignee (present on action in ('assigned', 'unassigned'))
    safe_cast(nullif(trim(json_value(payload, '$.assignee.id')), '') as int64) as assignee_id,
    nullif(trim(json_value(payload, '$.assignee.node_id')), '') as assignee_node_id,                                 -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.assignee.login')), '')) as assignee_name,
    lower(nullif(trim(json_value(payload, '$.assignee.type')), '')) as assignee_type,
    lower(nullif(trim(json_value(payload, '$.assignee.user_view_type')), '')) as assignee_user_view_type,
    nullif(trim(json_value(payload, '$.assignee.gravatar_id')), '') as assignee_gravatar_id,                         -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.assignee.site_admin')), '') as bool) as assignee_site_admin,
    nullif(trim(json_value(payload, '$.assignee.avatar_url')), '') as assignee_avatar_url,                            -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.url')), '') as assignee_object_url,                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.html_url')), '') as assignee_html_url,                               -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.events_url')), '') as assignee_events_url,                           -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.followers_url')), '') as assignee_followers_url,                     -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.following_url')), '') as assignee_following_url,                     -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.gists_url')), '') as assignee_gists_url,                             -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.organizations_url')), '') as assignee_organizations_url,             -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.received_events_url')), '') as assignee_received_events_url,         -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.repos_url')), '') as assignee_repos_url,                             -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.starred_url')), '') as assignee_starred_url,                         -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.subscriptions_url')), '') as assignee_subscriptions_url,             -- case-sensitive
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'pull_request_event'
