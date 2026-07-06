select
    review_state,
    count(*) as reviews,
from
    `joshua-data.dw.mart_snp_fact__pr_reviews`
where true
    and review_submitted_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
    and review_state is not null
group by
    all
order by
    reviews desc
