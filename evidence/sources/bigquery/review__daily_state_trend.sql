select
    review_submitted_date,
    countif(review_state = 'approved')            as reviews_approved,
    countif(review_state = 'changes_requested')   as reviews_changes_requested,
    countif(review_state = 'commented')           as reviews_commented,
    countif(review_state = 'dismissed')           as reviews_dismissed,
from
    `joshua-data.dw.mart_snp_fact__pr_reviews`
where true
    and review_submitted_date between date_sub(current_date(), interval 90 day) and date_sub(current_date(), interval 1 day)
group by
    all
order by
    1
