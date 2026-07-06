with

flt__prs as (
    select
        pull_request_id,
        opened_at,
    from
        `joshua-data.dw.mart_snp_fact__pull_requests`
    where true
        and opened_date between date_sub(current_date(), interval 30 day) and date_sub(current_date(), interval 1 day)
        and opened_at is not null
),

flt__reviews as (
    select
        pull_request_id,
        review_submitted_at,
    from
        `joshua-data.dw.mart_snp_fact__pr_reviews`
    where true
        and review_submitted_date between date_sub(current_date(), interval 30 day) and date_sub(current_date(), interval 1 day)
),

agg__first_review as (
    select
        pull_request_id,
        min(review_submitted_at) as first_reviewed_at,
    from
        flt__reviews
    group by
        all
),

agg__pr_review_pairs as (
    select
        datetime_diff(datetime(f.first_reviewed_at), datetime(p.opened_at), minute) / 60.0 as hours_to_first_review,
    from
        flt__prs as p
        inner join agg__first_review as f
            using (pull_request_id)
    where true
        and f.first_reviewed_at > p.opened_at
),

agg__quantiles as (
    select
        approx_quantiles(hours_to_first_review, 100) as quantiles,
        count(*)                                     as reviewed_prs,
    from
        agg__pr_review_pairs
),

agg__reviews_30d as (
    select
        countif(review_submitted_date >= date_sub(current_date(), interval 30 day)) as reviews_30d,
        countif(review_state = 'approved' and review_submitted_date >= date_sub(current_date(), interval 30 day)) as reviews_approved_30d,
    from
        `joshua-data.dw.mart_snp_fact__pr_reviews`
    where true
        and review_submitted_date between date_sub(current_date(), interval 30 day) and date_sub(current_date(), interval 1 day)
)

select
    q.quantiles[offset(50)] as median_hours_to_first_review,
    q.quantiles[offset(90)] as p90_hours_to_first_review,
    q.reviewed_prs,
    r.reviews_30d,
    r.reviews_approved_30d,
    safe_divide(r.reviews_approved_30d, r.reviews_30d) as approval_rate,
from
    agg__quantiles as q,
    agg__reviews_30d as r
