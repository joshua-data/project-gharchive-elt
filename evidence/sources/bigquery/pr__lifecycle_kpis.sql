with

flt__prs as (
    select
        opened_date,
        first_merged_at,
        first_closed_at,
    from
        `joshua-data.dw.mart_snp_fact__pull_requests`
    where true
        and opened_date between date_sub(current_date(), interval 60 day) and date_sub(current_date(), interval 1 day)
),

agg__current as (
    select
        countif(opened_date >= date_sub(current_date(), interval 30 day))                                                                          as prs_opened,
        countif(opened_date >= date_sub(current_date(), interval 30 day) and first_merged_at is not null)                                          as prs_merged,
        countif(opened_date >= date_sub(current_date(), interval 30 day) and first_closed_at is not null and first_merged_at is null)              as prs_abandoned,
        countif(opened_date >= date_sub(current_date(), interval 30 day) and first_closed_at is null)                                              as prs_still_open,
    from
        flt__prs
),

agg__prev as (
    select
        countif(opened_date <  date_sub(current_date(), interval 30 day))                                                                          as prs_opened_prev,
        countif(opened_date <  date_sub(current_date(), interval 30 day) and first_merged_at is not null)                                          as prs_merged_prev,
        countif(opened_date <  date_sub(current_date(), interval 30 day) and first_closed_at is not null and first_merged_at is null)              as prs_abandoned_prev,
        countif(opened_date <  date_sub(current_date(), interval 30 day) and first_closed_at is null)                                              as prs_still_open_prev,
    from
        flt__prs
)

select
    prs_opened,
    prs_merged,
    prs_abandoned,
    prs_still_open,
    prs_opened_prev,
    prs_merged_prev,
    prs_abandoned_prev,
    prs_still_open_prev,
from
    agg__current,
    agg__prev
