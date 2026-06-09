select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- discussion
    safe_cast(nullif(trim(json_value(payload, '$.discussion.id')), '') as int64) as discussion_id,
    nullif(trim(json_value(payload, '$.discussion.node_id')), '') as discussion_node_id,                                                       -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.discussion.number')), '') as int64) as discussion_number,
    nullif(trim(json_value(payload, '$.discussion.title')), '') as discussion_title,                                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.body')), '') as discussion_body,                                                             -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.discussion.state')), '')) as discussion_state,
    lower(nullif(trim(json_value(payload, '$.discussion.state_reason')), '')) as discussion_state_reason,
    lower(nullif(trim(json_value(payload, '$.discussion.author_association')), '')) as discussion_author_association,
    lower(nullif(trim(json_value(payload, '$.discussion.active_lock_reason')), '')) as discussion_active_lock_reason,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.locked')), '') as bool) as discussion_locked,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.comments')), '') as int64) as discussion_comments,
    json_query_array(payload, '$.discussion.labels') as discussion_labels,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.discussion.created_at')), '') as timestamp)) as discussion_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.discussion.updated_at')), '') as timestamp)) as discussion_updated_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.discussion.answer_chosen_at')), '') as timestamp)) as discussion_answer_chosen_at,
    nullif(trim(json_value(payload, '$.discussion.answer_html_url')), '') as discussion_answer_html_url,                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.html_url')), '') as discussion_html_url,                                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.repository_url')), '') as discussion_repository_url,                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.timeline_url')), '') as discussion_timeline_url,                                      -- case-sensitive
    -- discussion.user
    safe_cast(nullif(trim(json_value(payload, '$.discussion.user.id')), '') as int64) as discussion_user_id,
    nullif(trim(json_value(payload, '$.discussion.user.node_id')), '') as discussion_user_node_id,                                             -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.discussion.user.login')), '')) as discussion_user_name,
    lower(nullif(trim(json_value(payload, '$.discussion.user.type')), '')) as discussion_user_type,
    lower(nullif(trim(json_value(payload, '$.discussion.user.user_view_type')), '')) as discussion_user_user_view_type,
    nullif(trim(json_value(payload, '$.discussion.user.gravatar_id')), '') as discussion_user_gravatar_id,                                     -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.discussion.user.site_admin')), '') as bool) as discussion_user_site_admin,
    nullif(trim(json_value(payload, '$.discussion.user.avatar_url')), '') as discussion_user_avatar_url,                                        -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.url')), '') as discussion_user_object_url,                                              -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.html_url')), '') as discussion_user_html_url,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.events_url')), '') as discussion_user_events_url,                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.followers_url')), '') as discussion_user_followers_url,                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.following_url')), '') as discussion_user_following_url,                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.gists_url')), '') as discussion_user_gists_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.organizations_url')), '') as discussion_user_organizations_url,                         -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.received_events_url')), '') as discussion_user_received_events_url,                     -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.repos_url')), '') as discussion_user_repos_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.starred_url')), '') as discussion_user_starred_url,                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.user.subscriptions_url')), '') as discussion_user_subscriptions_url,                         -- case-sensitive
    -- discussion.category
    safe_cast(nullif(trim(json_value(payload, '$.discussion.category.id')), '') as int64) as discussion_category_id,
    nullif(trim(json_value(payload, '$.discussion.category.node_id')), '') as discussion_category_node_id,                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.category.name')), '') as discussion_category_name,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.category.emoji')), '') as discussion_category_emoji,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.category.description')), '') as discussion_category_description,                             -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.discussion.category.slug')), '')) as discussion_category_slug,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.category.is_answerable')), '') as bool) as discussion_category_is_answerable,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.category.repository_id')), '') as int64) as discussion_category_repository_id,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.discussion.category.created_at')), '') as timestamp)) as discussion_category_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.discussion.category.updated_at')), '') as timestamp)) as discussion_category_updated_at,
    -- discussion.answer_chosen_by
    safe_cast(nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.id')), '') as int64) as discussion_answer_chosen_by_id,
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.node_id')), '') as discussion_answer_chosen_by_node_id,                     -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.login')), '')) as discussion_answer_chosen_by_name,
    lower(nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.type')), '')) as discussion_answer_chosen_by_type,
    lower(nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.user_view_type')), '')) as discussion_answer_chosen_by_user_view_type,
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.gravatar_id')), '') as discussion_answer_chosen_by_gravatar_id,             -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.site_admin')), '') as bool) as discussion_answer_chosen_by_site_admin,
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.avatar_url')), '') as discussion_answer_chosen_by_avatar_url,                -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.url')), '') as discussion_answer_chosen_by_object_url,                      -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.html_url')), '') as discussion_answer_chosen_by_html_url,                   -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.events_url')), '') as discussion_answer_chosen_by_events_url,               -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.followers_url')), '') as discussion_answer_chosen_by_followers_url,         -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.following_url')), '') as discussion_answer_chosen_by_following_url,         -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.gists_url')), '') as discussion_answer_chosen_by_gists_url,                 -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.organizations_url')), '') as discussion_answer_chosen_by_organizations_url, -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.received_events_url')), '') as discussion_answer_chosen_by_received_events_url, -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.repos_url')), '') as discussion_answer_chosen_by_repos_url,                 -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.starred_url')), '') as discussion_answer_chosen_by_starred_url,             -- case-sensitive
    nullif(trim(json_value(payload, '$.discussion.answer_chosen_by.subscriptions_url')), '') as discussion_answer_chosen_by_subscriptions_url, -- case-sensitive
    -- discussion.reactions
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions.total_count')), '') as int64) as discussion_reactions_total_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions."+1"')), '') as int64) as discussion_reactions_plus_one_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions."-1"')), '') as int64) as discussion_reactions_minus_one_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions.laugh')), '') as int64) as discussion_reactions_laugh_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions.confused')), '') as int64) as discussion_reactions_confused_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions.heart')), '') as int64) as discussion_reactions_heart_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions.hooray')), '') as int64) as discussion_reactions_hooray_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions.rocket')), '') as int64) as discussion_reactions_rocket_count,
    safe_cast(nullif(trim(json_value(payload, '$.discussion.reactions.eyes')), '') as int64) as discussion_reactions_eyes_count,
    nullif(trim(json_value(payload, '$.discussion.reactions.url')), '') as discussion_reactions_object_url,                                           -- case-sensitive
    -- changes (present on action = 'edited')
    nullif(trim(json_value(payload, '$.changes.title.from')), '') as changes_title_from,                                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.changes.body.from')), '') as changes_body_from,                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.changes.category.from.name')), '') as changes_category_from_name,                                       -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.changes.category.from.slug')), '')) as changes_category_from_slug,
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'discussion_event'
