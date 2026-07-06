with

agg__daily_orgs as (
    select
        org_id,
        sum(all_events_count)         as events_total,
        sum(pushes_count)             as pushes,
        sum(prs_opened_count)         as prs_opened,
        sum(prs_merged_closed_count)  as prs_merged,
        sum(pr_reviews_count)         as reviews,
        sum(issues_opened_count)      as issues_opened,
        count(distinct created_date)  as active_days,
    from
        `joshua-data.dw.mart_snp_fact__daily_org_dev_activities`
    where true
        and created_date between date_sub(current_date(), interval 30 day) and date_sub(current_date(), interval 1 day)
        and org_id is not null
    group by
        all
),

dim__top_orgs as (
    select
        org_id,
        events_total,
        pushes,
        prs_opened,
        prs_merged,
        reviews,
        issues_opened,
        active_days,
    from
        agg__daily_orgs
    order by
        events_total desc
    limit
        15
)

select
    coalesce(o.org_name, cast(t.org_id as string)) as org_name,
    o.org_object_url                               as org_url,
    t.events_total,
    t.pushes,
    t.prs_opened,
    t.prs_merged,
    t.reviews,
    t.issues_opened,
    t.active_days,
from
    dim__top_orgs as t
    left join `joshua-data.dw.core_scd1__orgs` as o
        using (org_id)
order by
    t.events_total desc
