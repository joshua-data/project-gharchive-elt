---
title: Community Leaderboards
---

<Details title="Data provenance">

Sourced from the `mart_snp_fact__daily_{repo,user,org}_dev_activities` periodic-snapshot facts, summed across the trailing 30 days (today − 30 through yesterday) and joined against `core_scd1__{repos,users,orgs}` for display names. The window matches the one used by the KPI cards elsewhere in the Evidence site.

</Details>

## Top repositories (last 30 days)

```sql top_repos
select * from bigquery.community__top_repos
```

<DataTable data={top_repos} rows=25 rowShading=true search=true>
    <Column id=repo_name       title="Repository"    align=left  wrap=true/>
    <Column id=events_total    title="Events"        fmt=num0    contentType=colorscale colorScale="#2563eb" />
    <Column id=pushes          title="Pushes"        fmt=num0    contentType=colorscale colorScale="#0ea5e9" />
    <Column id=prs_opened      title="PRs opened"    fmt=num0    contentType=colorscale colorScale="#8b5cf6" />
    <Column id=prs_merged      title="PRs merged"    fmt=num0    contentType=colorscale colorScale="#10b981" />
    <Column id=reviews         title="Reviews"       fmt=num0    contentType=colorscale colorScale="#f59e0b" />
    <Column id=issues_opened   title="Issues"        fmt=num0    contentType=colorscale colorScale="#ef4444" />
    <Column id=active_days     title="Active days"   fmt=num0    contentType=colorscale colorScale="#64748b" />
</DataTable>

## Top contributors (last 30 days)

```sql top_users
select * from bigquery.community__top_users
```

<DataTable data={top_users} rows=25 rowShading=true search=true>
    <Column id=user_name       title="User"          align=left  wrap=true/>
    <Column id=events_total    title="Events"        fmt=num0    contentType=colorscale colorScale="#2563eb" />
    <Column id=pushes          title="Pushes"        fmt=num0    contentType=colorscale colorScale="#0ea5e9" />
    <Column id=prs_opened      title="PRs opened"    fmt=num0    contentType=colorscale colorScale="#8b5cf6" />
    <Column id=prs_merged      title="PRs merged"    fmt=num0    contentType=colorscale colorScale="#10b981" />
    <Column id=reviews         title="Reviews"       fmt=num0    contentType=colorscale colorScale="#f59e0b" />
    <Column id=review_comments title="Review cmts"   fmt=num0    contentType=colorscale colorScale="#a78bfa" />
    <Column id=issues_opened   title="Issues"        fmt=num0    contentType=colorscale colorScale="#ef4444" />
    <Column id=active_days     title="Active days"   fmt=num0    contentType=colorscale colorScale="#64748b" />
</DataTable>

## Top organizations (last 30 days)

```sql top_orgs
select * from bigquery.community__top_orgs
```

<DataTable data={top_orgs} rows=15 rowShading=true search=true>
    <Column id=org_name        title="Organization"  align=left  wrap=true/>
    <Column id=events_total    title="Events"        fmt=num0    contentType=colorscale colorScale="#2563eb" />
    <Column id=pushes          title="Pushes"        fmt=num0    contentType=colorscale colorScale="#0ea5e9" />
    <Column id=prs_opened      title="PRs opened"    fmt=num0    contentType=colorscale colorScale="#8b5cf6" />
    <Column id=prs_merged      title="PRs merged"    fmt=num0    contentType=colorscale colorScale="#10b981" />
    <Column id=reviews         title="Reviews"       fmt=num0    contentType=colorscale colorScale="#f59e0b" />
    <Column id=issues_opened   title="Issues"        fmt=num0    contentType=colorscale colorScale="#ef4444" />
    <Column id=active_days     title="Active days"   fmt=num0    contentType=colorscale colorScale="#64748b" />
</DataTable>

<Alert status="warning">
The raw GHArchive event stream carries a lot of automated traffic. CI test bots, mirror repos, and preview-deployment services can dominate the "events" leaderboard while contributing almost nothing to review or PR-merge activity. Sort by <strong>PRs merged</strong> or <strong>Reviews</strong> to see more of the human-authored side.
</Alert>
