select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- forkee
    safe_cast(nullif(trim(json_value(payload, '$.forkee.id')), '') as int64) as forkee_id,
    nullif(trim(json_value(payload, '$.forkee.node_id')), '') as forkee_node_id,                                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.name')), '') as forkee_name,                                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.full_name')), '') as forkee_full_name,                                                         -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.forkee.visibility')), '')) as forkee_visibility,
    nullif(trim(json_value(payload, '$.forkee.description')), '') as forkee_description,                                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.homepage')), '') as forkee_homepage,                                                           -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.forkee.language')), '')) as forkee_language,
    nullif(trim(json_value(payload, '$.forkee.default_branch')), '') as forkee_default_branch,                                               -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.forkee.private')), '') as bool) as forkee_private,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.fork')), '') as bool) as forkee_fork,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.archived')), '') as bool) as forkee_archived,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.disabled')), '') as bool) as forkee_disabled,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.is_template')), '') as bool) as forkee_is_template,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.allow_forking')), '') as bool) as forkee_allow_forking,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.web_commit_signoff_required')), '') as bool) as forkee_web_commit_signoff_required,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.has_issues')), '') as bool) as forkee_has_issues,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.has_projects')), '') as bool) as forkee_has_projects,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.has_wiki')), '') as bool) as forkee_has_wiki,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.has_pages')), '') as bool) as forkee_has_pages,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.has_downloads')), '') as bool) as forkee_has_downloads,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.has_discussions')), '') as bool) as forkee_has_discussions,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.has_pull_requests')), '') as bool) as forkee_has_pull_requests,
    lower(nullif(trim(json_value(payload, '$.forkee.pull_request_creation_policy')), '')) as forkee_pull_request_creation_policy,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.size')), '') as int64) as forkee_size,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.stargazers_count')), '') as int64) as forkee_stargazers_count,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.watchers_count')), '') as int64) as forkee_watchers_count,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.watchers')), '') as int64) as forkee_watchers,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.forks_count')), '') as int64) as forkee_forks_count,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.forks')), '') as int64) as forkee_forks,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.open_issues_count')), '') as int64) as forkee_open_issues_count,
    safe_cast(nullif(trim(json_value(payload, '$.forkee.open_issues')), '') as int64) as forkee_open_issues,
    json_value_array(payload, '$.forkee.topics') as forkee_topics,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.forkee.created_at')), '') as timestamp)) as forkee_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.forkee.updated_at')), '') as timestamp)) as forkee_updated_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.forkee.pushed_at')), '') as timestamp)) as forkee_pushed_at,
    nullif(trim(json_value(payload, '$.forkee.url')), '') as forkee_object_url,                                                              -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.html_url')), '') as forkee_html_url,                                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.git_url')), '') as forkee_git_url,                                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.ssh_url')), '') as forkee_ssh_url,                                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.clone_url')), '') as forkee_clone_url,                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.svn_url')), '') as forkee_svn_url,                                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.mirror_url')), '') as forkee_mirror_url,                                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.archive_url')), '') as forkee_archive_url,                                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.assignees_url')), '') as forkee_assignees_url,                                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.blobs_url')), '') as forkee_blobs_url,                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.branches_url')), '') as forkee_branches_url,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.collaborators_url')), '') as forkee_collaborators_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.comments_url')), '') as forkee_comments_url,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.commits_url')), '') as forkee_commits_url,                                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.compare_url')), '') as forkee_compare_url,                                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.contents_url')), '') as forkee_contents_url,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.contributors_url')), '') as forkee_contributors_url,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.deployments_url')), '') as forkee_deployments_url,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.downloads_url')), '') as forkee_downloads_url,                                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.events_url')), '') as forkee_events_url,                                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.forks_url')), '') as forkee_forks_url,                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.git_commits_url')), '') as forkee_git_commits_url,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.git_refs_url')), '') as forkee_git_refs_url,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.git_tags_url')), '') as forkee_git_tags_url,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.hooks_url')), '') as forkee_hooks_url,                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.issue_comment_url')), '') as forkee_issue_comment_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.issue_events_url')), '') as forkee_issue_events_url,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.issues_url')), '') as forkee_issues_url,                                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.keys_url')), '') as forkee_keys_url,                                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.labels_url')), '') as forkee_labels_url,                                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.languages_url')), '') as forkee_languages_url,                                                 -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.merges_url')), '') as forkee_merges_url,                                                       -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.milestones_url')), '') as forkee_milestones_url,                                               -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.notifications_url')), '') as forkee_notifications_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.pulls_url')), '') as forkee_pulls_url,                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.releases_url')), '') as forkee_releases_url,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.stargazers_url')), '') as forkee_stargazers_url,                                               -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.statuses_url')), '') as forkee_statuses_url,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.subscribers_url')), '') as forkee_subscribers_url,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.subscription_url')), '') as forkee_subscription_url,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.tags_url')), '') as forkee_tags_url,                                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.teams_url')), '') as forkee_teams_url,                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.trees_url')), '') as forkee_trees_url,                                                         -- case-sensitive
    -- forkee.owner
    safe_cast(nullif(trim(json_value(payload, '$.forkee.owner.id')), '') as int64) as forkee_owner_id,
    nullif(trim(json_value(payload, '$.forkee.owner.node_id')), '') as forkee_owner_node_id,                                                 -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.forkee.owner.login')), '')) as forkee_owner_name,
    lower(nullif(trim(json_value(payload, '$.forkee.owner.type')), '')) as forkee_owner_type,
    lower(nullif(trim(json_value(payload, '$.forkee.owner.user_view_type')), '')) as forkee_owner_user_view_type,
    nullif(trim(json_value(payload, '$.forkee.owner.gravatar_id')), '') as forkee_owner_gravatar_id,                                         -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.forkee.owner.site_admin')), '') as bool) as forkee_owner_site_admin,
    nullif(trim(json_value(payload, '$.forkee.owner.avatar_url')), '') as forkee_owner_avatar_url,                                            -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.url')), '') as forkee_owner_object_url,                                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.html_url')), '') as forkee_owner_html_url,                                               -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.events_url')), '') as forkee_owner_events_url,                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.followers_url')), '') as forkee_owner_followers_url,                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.following_url')), '') as forkee_owner_following_url,                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.gists_url')), '') as forkee_owner_gists_url,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.organizations_url')), '') as forkee_owner_organizations_url,                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.received_events_url')), '') as forkee_owner_received_events_url,                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.repos_url')), '') as forkee_owner_repos_url,                                             -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.starred_url')), '') as forkee_owner_starred_url,                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.owner.subscriptions_url')), '') as forkee_owner_subscriptions_url,                             -- case-sensitive
    -- forkee.license
    lower(nullif(trim(json_value(payload, '$.forkee.license.key')), '')) as forkee_license_key,
    nullif(trim(json_value(payload, '$.forkee.license.name')), '') as forkee_license_name,                                                   -- case-sensitive
    nullif(trim(json_value(payload, '$.forkee.license.node_id')), '') as forkee_license_node_id,                                             -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.forkee.license.spdx_id')), '')) as forkee_license_spdx_id,
    nullif(trim(json_value(payload, '$.forkee.license.url')), '') as forkee_license_object_url,                                              -- case-sensitive
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'fork_event'
