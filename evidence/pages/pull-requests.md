---
title: Pull Request Pipeline
---

<Details title="Data provenance">

Sourced from `mart_snp_fact__pull_requests`, an accumulating-snapshot fact keyed on `pull_request_id`. Every PR is folded into a single row that grows as new events (open, reopen, close, merge) arrive. Windows below key on `opened_date`. The 30-day window feeds the KPI cards, and the 90-day window drives the trend charts.

</Details>

```sql pr_kpis
select * from bigquery.pr__lifecycle_kpis
```

```sql pr_trend
select * from bigquery.pr__lifecycle_trend
```

```sql ttm_stats
select * from bigquery.pr__time_to_merge_stats
```

```sql ttm_dist
select * from bigquery.pr__time_to_merge_distribution
```

## Pipeline volume (last 30 days)

<Grid cols=4>
    <BigValue
        data={pr_kpis}
        value=prs_opened
        title="PRs opened"
        comparison=prs_opened_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
    <BigValue
        data={pr_kpis}
        value=prs_merged
        title="PRs merged"
        comparison=prs_merged_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
    <BigValue
        data={pr_kpis}
        value=prs_abandoned
        title="PRs abandoned"
        comparison=prs_abandoned_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
    <BigValue
        data={pr_kpis}
        value=prs_still_open
        title="Still open"
        comparison=prs_still_open_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
</Grid>

## Lifecycle outcomes per day

<AreaChart
    data={pr_trend}
    x=opened_date
    y={['prs_merged', 'prs_abandoned', 'prs_still_open']}
    seriesColors={['#10b981', '#ef4444', '#f59e0b']}
    title="Outcomes by open day (stacked)"
    yAxisTitle="pull requests"
    chartAreaHeight=280
/>

<Alert status="info">
A PR counts as <strong>merged</strong> once a merge event lands, <strong>abandoned</strong> if it was closed without ever merging, and <strong>still open</strong> when no close event has arrived. Cohorts on the right edge lean toward "still open" because later batches haven't caught up yet.
</Alert>

## Time to merge (last 30 days)

<Grid cols=3>
    <BigValue
        data={ttm_stats}
        value=median_hours_to_merge
        title="Median (h)"
        fmt=num1
    />
    <BigValue
        data={ttm_stats}
        value=p90_hours_to_merge
        title="p90 (h)"
        fmt=num1
    />
    <BigValue
        data={ttm_stats}
        value=p99_hours_to_merge
        title="p99 (h)"
        fmt=num1
    />
</Grid>

<BarChart
    data={ttm_dist}
    x=time_to_merge_bucket
    y=prs
    title="Time-to-merge distribution (last 90 days)"
    yAxisTitle="pull requests merged"
    swapXY=false
    fillColor="#2563eb"
    chartAreaHeight=260
    sort=false
/>

<DataTable data={ttm_dist} rowShading=true>
    <Column id=time_to_merge_bucket title="Bucket"      align=left/>
    <Column id=prs                  title="PRs merged"  fmt=num0    contentType=colorscale colorScale="#2563eb" />
</DataTable>
