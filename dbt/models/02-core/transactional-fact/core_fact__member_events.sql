select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- member
    safe_cast(nullif(trim(json_value(payload, '$.member.id')), '') as int64) as member_id,
    nullif(trim(json_value(payload, '$.member.node_id')), '') as member_node_id,                             -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.member.login')), '')) as member_name,
    lower(nullif(trim(json_value(payload, '$.member.type')), '')) as member_type,
    lower(nullif(trim(json_value(payload, '$.member.user_view_type')), '')) as member_user_view_type,
    nullif(trim(json_value(payload, '$.member.gravatar_id')), '') as member_gravatar_id,                     -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.member.site_admin')), '') as bool) as member_site_admin,
    nullif(trim(json_value(payload, '$.member.avatar_url')), '') as member_avatar_url,                        -- case-sensitive
    nullif(trim(json_value(payload, '$.member.url')), '') as member_object_url,                              -- case-sensitive
    nullif(trim(json_value(payload, '$.member.html_url')), '') as member_html_url,                           -- case-sensitive
    nullif(trim(json_value(payload, '$.member.events_url')), '') as member_events_url,                       -- case-sensitive
    nullif(trim(json_value(payload, '$.member.followers_url')), '') as member_followers_url,                 -- case-sensitive
    nullif(trim(json_value(payload, '$.member.following_url')), '') as member_following_url,                 -- case-sensitive
    nullif(trim(json_value(payload, '$.member.gists_url')), '') as member_gists_url,                         -- case-sensitive
    nullif(trim(json_value(payload, '$.member.organizations_url')), '') as member_organizations_url,         -- case-sensitive
    nullif(trim(json_value(payload, '$.member.received_events_url')), '') as member_received_events_url,     -- case-sensitive
    nullif(trim(json_value(payload, '$.member.repos_url')), '') as member_repos_url,                         -- case-sensitive
    nullif(trim(json_value(payload, '$.member.starred_url')), '') as member_starred_url,                     -- case-sensitive
    nullif(trim(json_value(payload, '$.member.subscriptions_url')), '') as member_subscriptions_url,         -- case-sensitive
    -- changes
    nullif(trim(json_value(payload, '$.changes.permission.from')), '') as changes_permission_from,           -- case-sensitive
    nullif(trim(json_value(payload, '$.changes.permission.to')), '') as changes_permission_to,               -- case-sensitive
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'member_event'
