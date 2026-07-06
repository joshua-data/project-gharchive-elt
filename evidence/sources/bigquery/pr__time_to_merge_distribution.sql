with

flt__merged_prs as (
    select
        datetime_diff(datetime(first_merged_at), datetime(opened_at), minute) / 60.0 as hours_to_merge,
    from
        `joshua-data.dw.mart_snp_fact__pull_requests`
    where true
        and opened_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
        and first_merged_at is not null
        and opened_at        is not null
),

bkt__merged_prs as (
    select
        case
            when hours_to_merge <  1   then '< 1h'
            when hours_to_merge <  6   then '1-6h'
            when hours_to_merge < 24   then '6-24h'
            when hours_to_merge < 72   then '1-3d'
            when hours_to_merge < 168  then '3-7d'
            when hours_to_merge < 720  then '7-30d'
            else                            '30d+'
        end as time_to_merge_bucket,
    from
        flt__merged_prs
)

select
    time_to_merge_bucket,
    count(*) as prs,
from
    bkt__merged_prs
group by
    all
order by
    case time_to_merge_bucket
        when '< 1h'  then 0
        when '1-6h'  then 1
        when '6-24h' then 2
        when '1-3d'  then 3
        when '3-7d'  then 4
        when '7-30d' then 5
        else              6
    end
