select
    -- Grain
    review_id,
    -- Identifiers
    pull_request_id,
    pull_request_number,
    -- Actors
    review_user_id,
    review_user_type,
    org_id,
    -- Repos
    pull_request_base_repo_id as base_repo_id,
    regexp_extract(pull_request_base_repo_object_url, r'/repos/(.+)$') as base_repo_name,
    pull_request_head_repo_id as head_repo_id,
    regexp_extract(pull_request_head_repo_object_url, r'/repos/(.+)$') as head_repo_name,
    -- Timestamps
    review_submitted_at,
    date(review_submitted_at) as review_submitted_date,
    review_updated_at,
    date(review_updated_at) as review_updated_date,
    -- State
    review_state,
    -- Content
    review_body,
from
    {{ ref('core_fact__pull_request_review_events') }}
where
    {{ batch_filter(date_col='created_date') }}
qualify
    row_number() over (
        partition by review_id
        order by event_id desc
    ) = 1
