with

agg__daily_users as (
    select
        created_date,
        count(distinct user_id) as active_users,
    from
        `joshua-data.dw.mart_snp_fact__daily_user_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
    group by
        all
),

agg__daily_orgs as (
    select
        created_date,
        count(distinct org_id) as active_orgs,
    from
        `joshua-data.dw.mart_snp_fact__daily_org_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
    group by
        all
),

agg__daily_repos as (
    select
        created_date,
        sum(all_events_count) as events_total,
        count(distinct repo_id) as active_repos,
    from
        `joshua-data.dw.mart_snp_fact__daily_repo_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
    group by
        all
)

select
    r.created_date,
    r.events_total,
    u.active_users,
    r.active_repos,
    o.active_orgs,
from
    agg__daily_repos as r
    left join agg__daily_users as u
        using (created_date)
    left join agg__daily_orgs as o
        using (created_date)
order by
    1
