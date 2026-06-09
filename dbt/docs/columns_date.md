{% docs date %}

Calendar date (UTC). Not null.

Usage across tables:
  - `core_snp_fact__daily_active_{users,repos,orgs}.date` — the calendar day
    the entity was active on.
  - `core_snp_fact__weekly_active_{users,repos,orgs}.date` — the **Sunday that
    starts the week** the row reports on (`DATE_TRUNC(..., WEEK(SUNDAY))`).
  - `core_snp_fact__monthly_active_{users,repos,orgs}.date` — the **first day
    of the calendar month** the row reports on (`DATE_TRUNC(..., MONTH)`).

In the weekly / monthly AU rollups the row's measures (`events_count`,
`active_days`) are **period-to-date** from `date` through the current
`batch_date` — partial mid-period, full once the period closes.

{% enddocs %}
