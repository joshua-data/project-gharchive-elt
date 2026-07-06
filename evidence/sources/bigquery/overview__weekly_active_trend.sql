with

agg__weekly_users as (
    select
        created_date as week_start_date,
        count(distinct user_id) as active_users,
    from
        `joshua-data.dw.mart_snp_fact__weekly_user_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 180 day) and date_sub(current_date(), interval 1 day)
    group by
        all
),

agg__weekly_repos as (
    select
        created_date as week_start_date,
        sum(all_events_count) as events_total,
        count(distinct repo_id) as active_repos,
    from
        `joshua-data.dw.mart_snp_fact__weekly_repo_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 180 day) and date_sub(current_date(), interval 1 day)
    group by
        all
)

select
    r.week_start_date,
    r.events_total,
    u.active_users,
    r.active_repos,
from
    agg__weekly_repos as r
    left join agg__weekly_users as u
        using (week_start_date)
order by
    1
