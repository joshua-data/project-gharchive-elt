---
title: Code Review Culture
---

<Details title="Data provenance">

Sourced from `mart_snp_fact__pr_reviews` (one row per review submitted), joined against `mart_snp_fact__pull_requests` for the coverage buckets. Reviews window on `review_submitted_date`, parent PRs window on `opened_date`. KPIs cover 30 days; the trend chart covers 90.

</Details>

```sql velocity
select * from bigquery.review__velocity_stats
```

```sql state_dist
select * from bigquery.review__state_distribution
```

```sql coverage
select * from bigquery.review__coverage_buckets
```

```sql state_trend
select * from bigquery.review__daily_state_trend
```

## Review activity (last 30 days)

<Grid cols=3>
    <BigValue
        data={velocity}
        value=reviews_30d
        title="Reviews submitted"
        fmt=num0
    />
    <BigValue
        data={velocity}
        value=approval_rate
        title="Approval rate"
        fmt=pct1
    />
    <BigValue
        data={velocity}
        value=median_hours_to_first_review
        title="Median hours to first review"
        fmt=num1
    />
</Grid>

## Coverage: reviews per PR

<Grid cols=2>
    <BarChart
        data={coverage}
        x=reviews_bucket
        y=prs
        title="How many reviews does a PR get?"
        yAxisTitle="pull requests"
        swapXY=false
        fillColor="#8b5cf6"
        chartAreaHeight=260
        sort=false
    />
    <ECharts config={{
        title: { text: 'Review state distribution', left: 'center', textStyle: { fontSize: 14 } },
        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
        legend: { orient: 'vertical', left: 'left', top: 'middle' },
        color: ['#10b981', '#ef4444', '#0ea5e9', '#64748b'],
        series: [{
            type: 'pie',
            radius: ['45%', '70%'],
            avoidLabelOverlap: true,
            itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
            label: { formatter: '{b}\n{d}%' },
            data: [...state_dist].map(row => ({
                name: row.review_state,
                value: Number(row.reviews)
            }))
        }]
    }}/>
</Grid>

<Alert status="info">
Coverage counts review submissions in the 90-day window against PRs opened in the same window. Since the two windows are applied independently, a PR opened right at the edge whose reviews arrive slightly after the cutoff will land in the "0" bucket.
</Alert>

## Reviews per day by state (last 90 days)

<AreaChart
    data={state_trend}
    x=review_submitted_date
    y={['reviews_approved', 'reviews_changes_requested', 'reviews_commented', 'reviews_dismissed']}
    seriesColors={['#10b981', '#ef4444', '#0ea5e9', '#64748b']}
    title="Daily review volume, stacked by state"
    yAxisTitle="reviews"
    chartAreaHeight=280
/>

<DataTable data={coverage} rowShading=true>
    <Column id=reviews_bucket title="Reviews per PR"       align=left/>
    <Column id=prs            title="Pull requests"        fmt=num0   contentType=colorscale colorScale="#8b5cf6" />
</DataTable>
