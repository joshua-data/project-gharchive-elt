select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- issue
    safe_cast(nullif(trim(json_value(payload, '$.issue.id')), '') as int64) as issue_id,
    nullif(trim(json_value(payload, '$.issue.node_id')), '') as issue_node_id,                                                       -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.issue.number')), '') as int64) as issue_number,
    nullif(trim(json_value(payload, '$.issue.title')), '') as issue_title,                                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.body')), '') as issue_body,                                                             -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.issue.state')), '')) as issue_state,
    lower(nullif(trim(json_value(payload, '$.issue.state_reason')), '')) as issue_state_reason,
    lower(nullif(trim(json_value(payload, '$.issue.author_association')), '')) as issue_author_association,
    lower(nullif(trim(json_value(payload, '$.issue.active_lock_reason')), '')) as issue_active_lock_reason,
    safe_cast(nullif(trim(json_value(payload, '$.issue.locked')), '') as bool) as issue_locked,
    safe_cast(nullif(trim(json_value(payload, '$.issue.draft')), '') as bool) as issue_draft,
    safe_cast(nullif(trim(json_value(payload, '$.issue.comments')), '') as int64) as issue_comments,
    json_query_array(payload, '$.issue.labels') as issue_labels,
    json_query_array(payload, '$.issue.assignees') as issue_assignees,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.created_at')), '') as timestamp)) as issue_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.updated_at')), '') as timestamp)) as issue_updated_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.closed_at')), '') as timestamp)) as issue_closed_at,
    nullif(trim(json_value(payload, '$.issue.url')), '') as issue_object_url,                                                        -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.html_url')), '') as issue_html_url,                                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.repository_url')), '') as issue_repository_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.labels_url')), '') as issue_labels_url,                                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.comments_url')), '') as issue_comments_url,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.events_url')), '') as issue_events_url,                                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.timeline_url')), '') as issue_timeline_url,                                             -- case-sensitive
    -- issue.user
    safe_cast(nullif(trim(json_value(payload, '$.issue.user.id')), '') as int64) as issue_user_id,
    nullif(trim(json_value(payload, '$.issue.user.node_id')), '') as issue_user_node_id,                                             -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.issue.user.login')), '')) as issue_user_name,
    lower(nullif(trim(json_value(payload, '$.issue.user.type')), '')) as issue_user_type,
    lower(nullif(trim(json_value(payload, '$.issue.user.user_view_type')), '')) as issue_user_user_view_type,
    nullif(trim(json_value(payload, '$.issue.user.gravatar_id')), '') as issue_user_gravatar_id,                                     -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.issue.user.site_admin')), '') as bool) as issue_user_site_admin,
    nullif(trim(json_value(payload, '$.issue.user.avatar_url')), '') as issue_user_avatar_url,                                        -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.url')), '') as issue_user_object_url,                                              -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.html_url')), '') as issue_user_html_url,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.events_url')), '') as issue_user_events_url,                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.followers_url')), '') as issue_user_followers_url,                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.following_url')), '') as issue_user_following_url,                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.gists_url')), '') as issue_user_gists_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.organizations_url')), '') as issue_user_organizations_url,                         -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.received_events_url')), '') as issue_user_received_events_url,                     -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.repos_url')), '') as issue_user_repos_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.starred_url')), '') as issue_user_starred_url,                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.user.subscriptions_url')), '') as issue_user_subscriptions_url,                         -- case-sensitive
    -- issue.assignee
    safe_cast(nullif(trim(json_value(payload, '$.issue.assignee.id')), '') as int64) as issue_assignee_id,
    nullif(trim(json_value(payload, '$.issue.assignee.node_id')), '') as issue_assignee_node_id,                                     -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.issue.assignee.login')), '')) as issue_assignee_name,
    lower(nullif(trim(json_value(payload, '$.issue.assignee.type')), '')) as issue_assignee_type,
    lower(nullif(trim(json_value(payload, '$.issue.assignee.user_view_type')), '')) as issue_assignee_user_view_type,
    safe_cast(nullif(trim(json_value(payload, '$.issue.assignee.site_admin')), '') as bool) as issue_assignee_site_admin,
    nullif(trim(json_value(payload, '$.issue.assignee.avatar_url')), '') as issue_assignee_avatar_url,                                -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.assignee.url')), '') as issue_assignee_object_url,                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.assignee.html_url')), '') as issue_assignee_html_url,                                   -- case-sensitive
    -- issue.milestone
    safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.id')), '') as int64) as issue_milestone_id,
    nullif(trim(json_value(payload, '$.issue.milestone.node_id')), '') as issue_milestone_node_id,                                   -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.number')), '') as int64) as issue_milestone_number,
    nullif(trim(json_value(payload, '$.issue.milestone.title')), '') as issue_milestone_title,                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.milestone.description')), '') as issue_milestone_description,                           -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.issue.milestone.state')), '')) as issue_milestone_state,
    safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.open_issues')), '') as int64) as issue_milestone_open_issues,
    safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.closed_issues')), '') as int64) as issue_milestone_closed_issues,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.due_on')), '') as timestamp)) as issue_milestone_due_on,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.created_at')), '') as timestamp)) as issue_milestone_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.updated_at')), '') as timestamp)) as issue_milestone_updated_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.closed_at')), '') as timestamp)) as issue_milestone_closed_at,
    nullif(trim(json_value(payload, '$.issue.milestone.url')), '') as issue_milestone_object_url,                                    -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.milestone.html_url')), '') as issue_milestone_html_url,                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.milestone.labels_url')), '') as issue_milestone_labels_url,                             -- case-sensitive
    -- issue.milestone.creator
    safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.creator.id')), '') as int64) as issue_milestone_creator_id,
    nullif(trim(json_value(payload, '$.issue.milestone.creator.node_id')), '') as issue_milestone_creator_node_id,                   -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.issue.milestone.creator.login')), '')) as issue_milestone_creator_name,
    lower(nullif(trim(json_value(payload, '$.issue.milestone.creator.type')), '')) as issue_milestone_creator_type,
    safe_cast(nullif(trim(json_value(payload, '$.issue.milestone.creator.site_admin')), '') as bool) as issue_milestone_creator_site_admin,
    nullif(trim(json_value(payload, '$.issue.milestone.creator.avatar_url')), '') as issue_milestone_creator_avatar_url,              -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.milestone.creator.url')), '') as issue_milestone_creator_object_url,                    -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.milestone.creator.html_url')), '') as issue_milestone_creator_html_url,                 -- case-sensitive
    -- issue.pull_request
    nullif(trim(json_value(payload, '$.issue.pull_request.url')), '') as issue_pull_request_object_url,                              -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.pull_request.html_url')), '') as issue_pull_request_html_url,                           -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.pull_request.diff_url')), '') as issue_pull_request_diff_url,                           -- case-sensitive
    nullif(trim(json_value(payload, '$.issue.pull_request.patch_url')), '') as issue_pull_request_patch_url,                         -- case-sensitive
    datetime(safe_cast(nullif(trim(json_value(payload, '$.issue.pull_request.merged_at')), '') as timestamp)) as issue_pull_request_merged_at,
    -- issue.reactions
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions.total_count')), '') as int64) as issue_reactions_total_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions."+1"')), '') as int64) as issue_reactions_plus_one_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions."-1"')), '') as int64) as issue_reactions_minus_one_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions.laugh')), '') as int64) as issue_reactions_laugh_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions.confused')), '') as int64) as issue_reactions_confused_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions.heart')), '') as int64) as issue_reactions_heart_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions.hooray')), '') as int64) as issue_reactions_hooray_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions.rocket')), '') as int64) as issue_reactions_rocket_count,
    safe_cast(nullif(trim(json_value(payload, '$.issue.reactions.eyes')), '') as int64) as issue_reactions_eyes_count,
    -- assignee (present on action = 'assigned' / 'unassigned')
    safe_cast(nullif(trim(json_value(payload, '$.assignee.id')), '') as int64) as assignee_id,
    nullif(trim(json_value(payload, '$.assignee.node_id')), '') as assignee_node_id,                                                 -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.assignee.login')), '')) as assignee_name,
    lower(nullif(trim(json_value(payload, '$.assignee.type')), '')) as assignee_type,
    lower(nullif(trim(json_value(payload, '$.assignee.user_view_type')), '')) as assignee_user_view_type,
    safe_cast(nullif(trim(json_value(payload, '$.assignee.site_admin')), '') as bool) as assignee_site_admin,
    nullif(trim(json_value(payload, '$.assignee.avatar_url')), '') as assignee_avatar_url,                                            -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.url')), '') as assignee_object_url,                                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.assignee.html_url')), '') as assignee_html_url,                                               -- case-sensitive
    -- label (present on action = 'labeled' / 'unlabeled')
    safe_cast(nullif(trim(json_value(payload, '$.label.id')), '') as int64) as label_id,
    nullif(trim(json_value(payload, '$.label.node_id')), '') as label_node_id,                                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.label.name')), '') as label_name,                                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.label.description')), '') as label_description,                                               -- case-sensitive
    nullif(trim(json_value(payload, '$.label.color')), '') as label_color,                                                           -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.label.default')), '') as bool) as label_default,
    nullif(trim(json_value(payload, '$.label.url')), '') as label_object_url,                                                        -- case-sensitive
    -- changes (present on action = 'edited')
    nullif(trim(json_value(payload, '$.changes.title.from')), '') as changes_title_from,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.changes.body.from')), '') as changes_body_from,                                               -- case-sensitive
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'issues_event'
