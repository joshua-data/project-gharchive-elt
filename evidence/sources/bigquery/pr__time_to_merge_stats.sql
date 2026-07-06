with

flt__merged_prs as (
    select
        datetime_diff(datetime(first_merged_at), datetime(opened_at), minute) / 60.0 as hours_to_merge,
    from
        `joshua-data.dw.mart_snp_fact__pull_requests`
    where true
        and opened_date between date_sub(current_date(), interval 30 day) and date_sub(current_date(), interval 1 day)
        and first_merged_at is not null
        and opened_at        is not null
),

agg__quantiles as (
    select
        approx_quantiles(hours_to_merge, 100) as quantiles,
        count(*)                              as merged_prs,
    from
        flt__merged_prs
)

select
    quantiles[offset(50)] as median_hours_to_merge,
    quantiles[offset(90)] as p90_hours_to_merge,
    quantiles[offset(99)] as p99_hours_to_merge,
    merged_prs,
from
    agg__quantiles
