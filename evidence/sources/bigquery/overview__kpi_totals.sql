with

flt__daily_users as (
    select
        created_date,
        user_id,
    from
        `joshua-data.dw.mart_snp_fact__daily_user_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 60 day) and date_sub(current_date(), interval 1 day)
),

flt__daily_orgs as (
    select
        created_date,
        org_id,
    from
        `joshua-data.dw.mart_snp_fact__daily_org_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 60 day) and date_sub(current_date(), interval 1 day)
),

flt__daily_repos as (
    select
        created_date,
        repo_id,
        all_events_count,
    from
        `joshua-data.dw.mart_snp_fact__daily_repo_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 60 day) and date_sub(current_date(), interval 1 day)
),

agg__events as (
    select
        sum(if(created_date >= date_sub(current_date(), interval 30 day), all_events_count, 0)) as events_total,
        sum(if(created_date <  date_sub(current_date(), interval 30 day), all_events_count, 0)) as events_total_prev,
    from
        flt__daily_repos
),

agg__users as (
    select
        count(distinct if(created_date >= date_sub(current_date(), interval 30 day), user_id, null)) as active_users,
        count(distinct if(created_date <  date_sub(current_date(), interval 30 day), user_id, null)) as active_users_prev,
    from
        flt__daily_users
),

agg__repos as (
    select
        count(distinct if(created_date >= date_sub(current_date(), interval 30 day), repo_id, null)) as active_repos,
        count(distinct if(created_date <  date_sub(current_date(), interval 30 day), repo_id, null)) as active_repos_prev,
    from
        flt__daily_repos
),

agg__orgs as (
    select
        count(distinct if(created_date >= date_sub(current_date(), interval 30 day), org_id, null)) as active_orgs,
        count(distinct if(created_date <  date_sub(current_date(), interval 30 day), org_id, null)) as active_orgs_prev,
    from
        flt__daily_orgs
)

select
    events_total,
    events_total_prev,
    active_users,
    active_users_prev,
    active_repos,
    active_repos_prev,
    active_orgs,
    active_orgs_prev,
from
    agg__events,
    agg__users,
    agg__repos,
    agg__orgs
