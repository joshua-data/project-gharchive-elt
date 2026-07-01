{% set interval = 'week(sunday)' %}

with

fact__events as (
    {{
        unify_events(
            shared_columns=['user_id', 'repo_id', 'org_id', 'created_date'],
            branches=[
                {'table': 'core_fact__commit_comment_events',              'event_name': 'commit_comment_event',               'extra_columns': ['action']                },
                {'table': 'core_fact__create_events',                      'event_name': 'create_event',                       'extra_columns': ['ref_type']              },
                {'table': 'core_fact__delete_events',                      'event_name': 'delete_event',                       'extra_columns': ['ref_type']              },
                {'table': 'core_fact__discussion_events',                  'event_name': 'discussion_event',                   'extra_columns': ['action']                },
                {'table': 'core_fact__fork_events',                        'event_name': 'fork_event',                         'extra_columns': ['action']                },
                {'table': 'core_fact__gollum_events',                      'event_name': 'gollum_event'                                                                   },
                {'table': 'core_fact__issue_comment_events',               'event_name': 'issue_comment_event',                'extra_columns': ['action']                },
                {'table': 'core_fact__issues_events',                      'event_name': 'issues_event',                       'extra_columns': ['action']                },
                {'table': 'core_fact__member_events',                      'event_name': 'member_event',                       'extra_columns': ['action']                },
                {'table': 'core_fact__pull_request_events',                'event_name': 'pull_request_event',                 'extra_columns': ['action']                },
                {'table': 'core_fact__pull_request_review_comment_events', 'event_name': 'pull_request_review_comment_event'                                              },
                {'table': 'core_fact__pull_request_review_events',         'event_name': 'pull_request_review_event',          'extra_columns': ['review_state as action']},
                {'table': 'core_fact__push_events',                        'event_name': 'push_event'                                                                     },
                {'table': 'core_fact__release_events',                     'event_name': 'release_event',                      'extra_columns': ['action']                },
                {'table': 'core_fact__watch_events',                       'event_name': 'watch_event',                        'extra_columns': ['action']                },
            ]
        )
    }}
)

select
    -- grain
    repo_id,
    date_trunc(created_date, {{ interval }}) as created_date,
    -- volume
    count(1) as all_events_count,
    count(distinct org_id) as unique_orgs_count,
    count(distinct user_id) as unique_users_count,
    -- pushes
    countif(event_name = 'push_event') as pushes_count,
    -- pull requests
    countif(event_name = 'pull_request_event' and action = 'opened') as prs_opened_count,
    countif(event_name = 'pull_request_event' and action = 'merged') as prs_merged_closed_count,
    countif(event_name = 'pull_request_event' and action = 'closed') as prs_unmerged_closed_count,
    countif(event_name = 'pull_request_event' and action in ('merged', 'closed')) as prs_total_closed_count,
    -- reviews
    countif(event_name = 'pull_request_review_event') as pr_reviews_count,
    countif(event_name = 'pull_request_review_event' and action = 'approved') as pr_reviews_approved_count,
    -- comments
    countif(event_name = 'pull_request_review_comment_event') as pr_review_comments_count,
    countif(event_name = 'issue_comment_event') as issue_comments_count,
    countif(event_name = 'commit_comment_event') as commit_comments_count,
    -- issues
    countif(event_name = 'issues_event' and action = 'opened') as issues_opened_count,
    countif(event_name = 'issues_event' and action = 'closed') as issues_closed_count,
    -- create or delete refs
    countif(event_name = 'create_event' and ref_type = 'branch') as branches_created_count,
    countif(event_name = 'delete_event' and ref_type = 'branch') as branches_deleted_count,
    -- releases
    countif(event_name = 'release_event') as releases_count,
    -- discussions, wiki, members
    countif(event_name = 'discussion_event') as discussions_count,
    countif(event_name = 'gollum_event') as wiki_pages_updated_count,
    countif(event_name = 'member_event') as members_updated_count,
    -- engagement signals
    countif(event_name = 'watch_event') as watches_count,
    countif(event_name = 'fork_event') as forks_count,
from
    fact__events
where true
    and {{ batch_filter(date_col='created_date', interval=interval) }}
    and repo_id is not null
group by
    all
