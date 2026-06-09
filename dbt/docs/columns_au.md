{% docs events_count %}

Total number of GitHub events triggered by this entity during the snapshot period
(day / week / month, depending on the table's grain). Always `> 0` — periods with
zero events do not produce a row (the AU table is a sparse activation snapshot,
not a dense calendar cross-join).

In rollup tables (weekly / monthly) this is the sum of the underlying daily
`events_count` values across the period.

{% enddocs %}


{% docs active_days %}

Number of distinct calendar days within the snapshot period the entity was
active (triggered at least one event). Range:
  - daily tables:   always 1 (kept so daily / weekly / monthly share a column shape).
  - weekly tables:  1–7
  - monthly tables: 1–31 (28–31 depending on the calendar month)

Always `≥ 1` — periods with zero active days do not produce a row.

In rollup tables (weekly / monthly) this is the sum of the underlying daily
`active_days` values across the period, which — because the daily table is
unique on `(<entity>_id, date)` — equals the count of distinct active days
in that period.

{% enddocs %}
