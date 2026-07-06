with

agg__daily_users as (
    select
        user_id,
        sum(all_events_count)         as events_total,
        sum(pushes_count)             as pushes,
        sum(prs_opened_count)         as prs_opened,
        sum(prs_merged_closed_count)  as prs_merged,
        sum(pr_reviews_count)         as reviews,
        sum(pr_review_comments_count) as review_comments,
        sum(issues_opened_count)      as issues_opened,
        count(distinct created_date)  as active_days,
    from
        `joshua-data.dw.mart_snp_fact__daily_user_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 30 day) and date_sub(current_date(), interval 1 day)
    group by
        all
),

dim__top_users as (
    select
        user_id,
        events_total,
        pushes,
        prs_opened,
        prs_merged,
        reviews,
        review_comments,
        issues_opened,
        active_days,
    from
        agg__daily_users
    order by
        events_total desc
    limit
        25
)

select
    coalesce(u.user_name, cast(t.user_id as string)) as user_name,
    u.user_object_url                                as user_url,
    t.events_total,
    t.pushes,
    t.prs_opened,
    t.prs_merged,
    t.reviews,
    t.review_comments,
    t.issues_opened,
    t.active_days,
from
    dim__top_users as t
    left join `joshua-data.dw.core_scd1__users` as u
        using (user_id)
order by
    t.events_total desc
