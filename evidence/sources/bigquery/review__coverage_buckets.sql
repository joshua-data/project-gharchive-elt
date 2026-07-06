with

flt__prs as (
    select
        pull_request_id,
    from
        `joshua-data.dw.mart_snp_fact__pull_requests`
    where true
        and opened_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
),

flt__reviews as (
    select
        pull_request_id,
        review_state,
    from
        `joshua-data.dw.mart_snp_fact__pr_reviews`
    where true
        and review_submitted_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
),

agg__reviews_per_pr as (
    select
        pull_request_id,
        count(*)                              as reviews_count,
        countif(review_state = 'approved')    as approvals_count,
    from
        flt__reviews
    group by
        all
),

dim__prs_with_review_counts as (
    select
        p.pull_request_id,
        coalesce(r.reviews_count,   0) as reviews_count,
        coalesce(r.approvals_count, 0) as approvals_count,
    from
        flt__prs as p
        left join agg__reviews_per_pr as r
            using (pull_request_id)
),

bkt__prs as (
    select
        case
            when reviews_count = 0            then '0'
            when reviews_count between 1 and 2 then '1-2'
            when reviews_count between 3 and 5 then '3-5'
            else                                    '6+'
        end as reviews_bucket,
    from
        dim__prs_with_review_counts
)

select
    reviews_bucket,
    count(*) as prs,
from
    bkt__prs
group by
    all
order by
    case reviews_bucket
        when '0'   then 0
        when '1-2' then 1
        when '3-5' then 2
        else            3
    end
