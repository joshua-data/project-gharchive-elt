with

-- ======================================
-- Load Source Tables
-- ======================================

fact__pr_events as (
    select
        event_id,
        created_date,
        created_at,
        user_id,
        org_id,
        action,
        pull_request_id,
        pull_request_number,
        pull_request_base_repo_id as base_repo_id,
        regexp_extract(pull_request_base_repo_object_url, r'/repos/(.+)$') as base_repo_name,
        pull_request_head_repo_id as head_repo_id,
        regexp_extract(pull_request_head_repo_object_url, r'/repos/(.+)$') as head_repo_name,
        labels,
    from
        {{ ref('core_fact__pull_request_events') }}
    where true
        and {{ batch_filter(date_col='created_date') }}
        and pull_request_id is not null
),

-- ======================================
-- Transform Dimension Tables
-- ======================================

dim__pr_milestones as (
    select
        pull_request_id,
        min(if(action = 'opened', date(created_at), null)) as opened_date,
        min(if(action = 'opened', created_at, null)) as opened_at,
        min(if(action = 'reopened', created_at, null)) as first_reopened_at,
        max(if(action = 'reopened', created_at, null)) as last_reopened_at,
        min(if(action = 'merged', created_at, null)) as first_merged_at,
        max(if(action = 'merged', created_at, null)) as last_merged_at,
        min(if(action in ('closed', 'merged'), created_at, null)) as first_closed_at,
        max(if(action in ('closed', 'merged'), created_at, null)) as last_closed_at,
        max(created_at) as last_action_at,
    from
        fact__pr_events
    group by
        all
),

-- latest dimensions
scd1__prs as (
    select
        pull_request_id,
        pull_request_number,
        org_id,
        base_repo_id,
        base_repo_name,
        head_repo_id,
        head_repo_name,
    from
        fact__pr_events
    qualify
        row_number() over (
            partition by pull_request_id
            order by created_at desc, event_id desc
        ) = 1
),

-- latest dimensions
scd1__pr_labels as (
    select
        pull_request_id,
        labels,
    from
        fact__pr_events
    where true
        and action in ('labeled', 'unlabeled')
    qualify
        row_number() over (
            partition by pull_request_id
            order by created_at desc, event_id desc
        ) = 1
),

-- first dimensions
dim__prs as (
    select
        pull_request_id,
        user_id as author_user_id,
    from
        fact__pr_events
    where true
        and action = 'opened'
    qualify
        row_number() over (
            partition by pull_request_id
            order by created_at, event_id
        ) = 1
),

-- ======================================
-- Final Results
-- ======================================

-- Per-PR view from this batch
latest as (
    select
        m.pull_request_id,
        scd1__prs.pull_request_number,
        scd1__prs.org_id,
        scd1__prs.base_repo_id,
        scd1__prs.base_repo_name,
        scd1__prs.head_repo_id,
        scd1__prs.head_repo_name,
        dim__prs.author_user_id,
        scd1__pr_labels.labels,
        m.opened_date,
        m.opened_at,
        m.first_reopened_at,
        m.last_reopened_at,
        m.first_merged_at,
        m.last_merged_at,
        m.first_closed_at,
        m.last_closed_at,
        m.last_action_at,
    from
        dim__pr_milestones as m
        left join dim__prs
            using (pull_request_id)
        left join scd1__prs
            using (pull_request_id)
        left join scd1__pr_labels
            using (pull_request_id)
),

-- Per-PR view from existing target table
existing as (
    select
        *
    {% if is_incremental() %}
    from
        {{ this }}
    where true
        and {{ reverse_batch_filter(date_col='opened_date') }}
    {% else %}
    from
        latest
    where false
    {% endif %}
)

-- Reconcile latest with existing
select
    latest.pull_request_id,
    coalesce(latest.pull_request_number, existing.pull_request_number) as pull_request_number,
    coalesce(latest.org_id, existing.org_id) as org_id,
    coalesce(latest.base_repo_id, existing.base_repo_id) as base_repo_id,
    coalesce(latest.base_repo_name, existing.base_repo_name) as base_repo_name,
    coalesce(latest.head_repo_id, existing.head_repo_id) as head_repo_id,
    coalesce(latest.head_repo_name, existing.head_repo_name) as head_repo_name,
    coalesce(latest.author_user_id, existing.author_user_id) as author_user_id,
    coalesce(latest.labels, existing.labels) as labels,
    coalesce(latest.opened_date, existing.opened_date) as opened_date,
    coalesce(latest.opened_at, existing.opened_at) as opened_at,
    -- least/greatest return null if ANY argument is null, so coalesce falls back to whichever value is non-null.
    coalesce(least(latest.first_reopened_at, existing.first_reopened_at), latest.first_reopened_at, existing.first_reopened_at) as first_reopened_at,
    coalesce(greatest(latest.last_reopened_at, existing.last_reopened_at), latest.last_reopened_at, existing.last_reopened_at) as last_reopened_at,
    coalesce(least(latest.first_merged_at, existing.first_merged_at), latest.first_merged_at, existing.first_merged_at) as first_merged_at,
    coalesce(greatest(latest.last_merged_at, existing.last_merged_at), latest.last_merged_at, existing.last_merged_at) as last_merged_at,
    coalesce(least(latest.first_closed_at, existing.first_closed_at), latest.first_closed_at, existing.first_closed_at) as first_closed_at,
    coalesce(greatest(latest.last_closed_at, existing.last_closed_at), latest.last_closed_at, existing.last_closed_at) as last_closed_at,
    coalesce(greatest(latest.last_action_at, existing.last_action_at), latest.last_action_at, existing.last_action_at) as last_action_at,
from
    latest
    left join existing
        using (pull_request_id)
where true
    -- The source doesn't capture all historical pull request events, so rows with no opened_date are incomplete — exclude them.
    and coalesce(latest.opened_date, existing.opened_date) is not null
