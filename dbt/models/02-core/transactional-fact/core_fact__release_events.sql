select
    * except (payload),
    -- action
    lower(nullif(trim(json_value(payload, '$.action')), '')) as action,
    -- release
    safe_cast(nullif(trim(json_value(payload, '$.release.id')), '') as int64) as release_id,
    nullif(trim(json_value(payload, '$.release.node_id')), '') as release_node_id,                                                                        -- case-sensitive
    nullif(trim(json_value(payload, '$.release.tag_name')), '') as release_tag_name,                                                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.release.target_commitish')), '') as release_target_commitish,                                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.release.name')), '') as release_name,                                                                              -- case-sensitive
    nullif(trim(json_value(payload, '$.release.body')), '') as release_body,                                                                              -- case-sensitive
    nullif(trim(json_value(payload, '$.release.short_description_html')), '') as release_short_description_html,                                          -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.release.is_short_description_html_truncated')), '') as bool) as release_is_short_description_html_truncated,
    safe_cast(nullif(trim(json_value(payload, '$.release.draft')), '') as bool) as release_draft,
    safe_cast(nullif(trim(json_value(payload, '$.release.prerelease')), '') as bool) as release_prerelease,
    safe_cast(nullif(trim(json_value(payload, '$.release.immutable')), '') as bool) as release_immutable,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.release.created_at')), '') as timestamp)) as release_created_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.release.updated_at')), '') as timestamp)) as release_updated_at,
    datetime(safe_cast(nullif(trim(json_value(payload, '$.release.published_at')), '') as timestamp)) as release_published_at,
    nullif(trim(json_value(payload, '$.release.url')), '') as release_object_url,                                                                         -- case-sensitive
    nullif(trim(json_value(payload, '$.release.html_url')), '') as release_html_url,                                                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.release.assets_url')), '') as release_assets_url,                                                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.release.upload_url')), '') as release_upload_url,                                                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.release.tarball_url')), '') as release_tarball_url,                                                                -- case-sensitive
    nullif(trim(json_value(payload, '$.release.zipball_url')), '') as release_zipball_url,                                                                -- case-sensitive
    nullif(trim(json_value(payload, '$.release.discussion_url')), '') as release_discussion_url,                                                          -- case-sensitive
    -- release.author
    safe_cast(nullif(trim(json_value(payload, '$.release.author.id')), '') as int64) as release_author_id,
    nullif(trim(json_value(payload, '$.release.author.node_id')), '') as release_author_node_id,                                                          -- case-sensitive
    lower(nullif(trim(json_value(payload, '$.release.author.login')), '')) as release_author_name,
    lower(nullif(trim(json_value(payload, '$.release.author.type')), '')) as release_author_type,
    lower(nullif(trim(json_value(payload, '$.release.author.user_view_type')), '')) as release_author_user_view_type,
    nullif(trim(json_value(payload, '$.release.author.gravatar_id')), '') as release_author_gravatar_id,                                                  -- case-sensitive
    safe_cast(nullif(trim(json_value(payload, '$.release.author.site_admin')), '') as bool) as release_author_site_admin,
    nullif(trim(json_value(payload, '$.release.author.avatar_url')), '') as release_author_avatar_url,                                                     -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.url')), '') as release_author_object_url,                                                           -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.html_url')), '') as release_author_html_url,                                                        -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.events_url')), '') as release_author_events_url,                                                    -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.followers_url')), '') as release_author_followers_url,                                              -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.following_url')), '') as release_author_following_url,                                              -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.gists_url')), '') as release_author_gists_url,                                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.organizations_url')), '') as release_author_organizations_url,                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.received_events_url')), '') as release_author_received_events_url,                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.repos_url')), '') as release_author_repos_url,                                                      -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.starred_url')), '') as release_author_starred_url,                                                  -- case-sensitive
    nullif(trim(json_value(payload, '$.release.author.subscriptions_url')), '') as release_author_subscriptions_url,                                      -- case-sensitive
    -- release.assets
    json_query_array(payload, '$.release.assets') as release_assets,
from
    {{ ref('stg_fact__events') }}
where true
    and {{ batch_filter(date_col='created_date') }}
    and event_name = 'release_event'
