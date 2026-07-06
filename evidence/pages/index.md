---
title: GHArchive Activity Overview
og:
  title: GHArchive Activity Overview
---

<Details title="What am I looking at?">

The public GitHub event stream, transformed by [dbt](/project-gharchive-elt/dbt-docs/) into curated marts on BigQuery and rendered by [Evidence.dev](https://evidence.dev). Headline KPIs cover the **last 30 UTC days**, and trends cover the **last 90 UTC days**. The current day is excluded because its batch hasn't landed yet.

</Details>

```sql kpis
select * from bigquery.overview__kpi_totals
```

```sql daily
select * from bigquery.overview__daily_activity
```

```sql weekly
select * from bigquery.overview__weekly_active_trend
```

## Headline KPIs (last 30 days)

<Grid cols=4>
    <BigValue
        data={kpis}
        value=events_total
        title="Events"
        comparison=events_total_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
    <BigValue
        data={kpis}
        value=active_users
        title="Active users"
        comparison=active_users_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
    <BigValue
        data={kpis}
        value=active_repos
        title="Active repos"
        comparison=active_repos_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
    <BigValue
        data={kpis}
        value=active_orgs
        title="Active orgs"
        comparison=active_orgs_prev
        comparisonTitle="vs. prior 30d"
        comparisonFmt=num0
        fmt=num0
    />
</Grid>

## Activity trends (last 90 days)

<Grid cols=2>
    <AreaChart
        data={daily}
        x=created_date
        y=events_total
        title="Daily event volume"
        yAxisTitle="events"
        fillColor="#2563eb"
        lineColor="#2563eb"
        chartAreaHeight=260
    />
    <LineChart
        data={daily}
        x=created_date
        y={['active_users', 'active_repos', 'active_orgs']}
        title="Daily active entities"
        yAxisTitle="unique count"
        chartAreaHeight=260
    />
</Grid>

<LineChart
    data={weekly}
    x=week_start_date
    y={['active_users', 'active_repos']}
    y2=events_total
    y2SeriesType=area
    title="Weekly rollup: active users, active repos, and total events"
    yAxisTitle="unique count"
    y2AxisTitle="events"
    chartAreaHeight=260
/>

## Top repositories (last 30 days)

```sql top_repos_mini
select
    repo_name,
    events_total,
    prs_opened,
    prs_merged,
    reviews,
    active_days,
from bigquery.community__top_repos
limit 10
```

<DataTable data={top_repos_mini} rowShading=true>
    <Column id=repo_name       title="Repository"    align=left  wrap=true/>
    <Column id=events_total    title="Events"        fmt=num0    contentType=colorscale colorScale="#2563eb" />
    <Column id=prs_opened      title="PRs opened"    fmt=num0    contentType=colorscale colorScale="#0ea5e9" />
    <Column id=prs_merged      title="PRs merged"    fmt=num0    contentType=colorscale colorScale="#10b981" />
    <Column id=reviews         title="Reviews"       fmt=num0    contentType=colorscale colorScale="#8b5cf6" />
    <Column id=active_days     title="Active days"   fmt=num0    contentType=colorscale colorScale="#f59e0b" />
</DataTable>

<Alert status="info">
The full leaderboard across repos, users, and organizations lives on the <a href="/community">Community</a> page. For deeper cuts into PR flow and review activity, head to <a href="/pull-requests">Pull Requests</a> or <a href="/reviews">Reviews</a>.
</Alert>
