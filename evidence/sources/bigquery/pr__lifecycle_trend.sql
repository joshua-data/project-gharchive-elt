select
    opened_date,
    count(*)                                                                as prs_opened,
    countif(first_merged_at is not null)                                    as prs_merged,
    countif(first_closed_at is not null and first_merged_at is null)        as prs_abandoned,
    countif(first_closed_at is null)                                        as prs_still_open,
from
    `joshua-data.dw.mart_snp_fact__pull_requests`
where true
    and opened_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
group by
    all
order by
    1
