# evidence

**What this is:** an [Evidence.dev](https://evidence.dev) static BI project that consumes the `dw.mart_snp_fact__*` marts and publishes a browsable site to GitHub Pages, sharing the same host and deploy model as the [dbt docs](https://joshua-data.github.io/project-gharchive-elt/dbt-docs/).

**How it runs:**
- **Chained to dbt-run.** GitHub Actions workflow [`evidence-build.yml`](../.github/workflows/evidence-build.yml) fires via `workflow_run` right after each successful [`dbt-run.yml`](../.github/workflows/dbt-run.yml) on `main`, and also on every push to `main` that touches `evidence/**` or on manual `workflow_dispatch`. Chaining gets rid of the multi-hour cron drift that used to leave the site building against yesterday's marts.
- **Local development.** You run as yourself via `gcloud auth application-default login`. No service account keys, no impersonation.

**Where the Evidence site lives:** <https://joshua-data.github.io/project-gharchive-elt/evidence/> (refreshed once per day after the dbt build lands, plus on every push to `main` that touches `evidence/**`).

> ↩ Back to [project overview](../README.md). For the mart definitions this site reads → [`../dbt/models/03-marts/`](../dbt/models/03-marts/).

## Pages

The Evidence site is broken into four pages, each grounded in a specific mart family:

| Page | Mart(s) | Focus |
|---|---|---|
| [Overview](pages/index.md) | `mart_snp_fact__daily_*_dev_activities`, `mart_snp_fact__weekly_*_dev_activities` | 30-day headline KPIs, 90-day trend charts, top-repo snapshot |
| [Pull Requests](pages/pull-requests.md) | `mart_snp_fact__pull_requests` | PR lifecycle outcomes, time-to-merge distribution and percentiles |
| [Reviews](pages/reviews.md) | `mart_snp_fact__pr_reviews`, `mart_snp_fact__pull_requests` | Review velocity, coverage buckets, state distribution |
| [Community](pages/community.md) | `mart_snp_fact__daily_*_dev_activities`, `core_scd1__{repos,users,orgs}` | Leaderboards for repositories, contributors, organizations |

## Why Evidence

The project already publishes dbt docs as static files on GitHub Pages, so a server-based BI tool (Metabase, Superset, Redash, Lightdash) would break the deployment model. Evidence compiles Markdown + SQL files to a static SvelteKit site. SQL runs against BigQuery **once, at CI build time**, results are materialized to Parquet, and the deployed browser reads those Parquet files via DuckDB-WASM. No credentials ship to the client, and no live warehouse call happens from the browser.

## Auth: Workload Identity Federation, no keys

The BigQuery source is configured with `authenticator: gcloud-cli`, which delegates entirely to Application Default Credentials. No client_email, no private_key. In CI, `google-github-actions/auth@v3` produces a short-lived external-account credentials file and exposes its path as `steps.<id>.outputs.credentials_file_path`, and the workflow exports that path as `GOOGLE_APPLICATION_CREDENTIALS` before invoking Evidence. The `@evidence-dev/bigquery` connector (v2.0.12) constructs `new BigQuery({ projectId, location })` in that mode, and `@google-cloud/bigquery` picks the ADC file up transparently.

Locally, ADC comes from `gcloud auth application-default login`. The `dw` dataset is readable by the same `gharchive-dbt-runner` service account that writes it (as it must be to materialize the tables), so no separate reader identity is needed.

## Layout

```
evidence/
├── package.json                                 scripts: dev / sources / build
├── evidence.config.yaml                         deployment.basePath, theme palette, page order
├── evidence.plugins.yaml                        @evidence-dev/core-components + bigquery
├── pages/
│   ├── index.md                                 Overview
│   ├── pull-requests.md                         PR pipeline
│   ├── reviews.md                               Review culture
│   └── community.md                             Repo / user / org leaderboards
└── sources/
    └── bigquery/
        ├── connection.yaml                      type: bigquery, authenticator: gcloud-cli
        ├── overview__kpi_totals.sql             30d KPI totals + prior-30d comparison
        ├── overview__daily_activity.sql         90d daily trend (events / users / repos / orgs)
        ├── overview__weekly_active_trend.sql    180d weekly rollup
        ├── pr__lifecycle_kpis.sql               30d PR outcome counters + comparison
        ├── pr__lifecycle_trend.sql              90d daily PR outcomes
        ├── pr__time_to_merge_stats.sql          median / p90 / p99 time-to-merge
        ├── pr__time_to_merge_distribution.sql   histogram (<1h, 1-6h, 6-24h, 1-3d, 3-7d, 7-30d, 30d+)
        ├── review__velocity_stats.sql           reviews submitted, approval rate, hours to first review
        ├── review__state_distribution.sql       approved / changes_requested / commented / dismissed shares
        ├── review__coverage_buckets.sql         reviews-per-PR bucketing
        ├── review__daily_state_trend.sql        90d daily reviews stacked by state
        ├── community__top_repos.sql             top 25 repositories over last 30d, joined with repo names
        ├── community__top_users.sql             top 25 contributors over last 30d, joined with user names
        └── community__top_orgs.sql              top 15 organizations over last 30d, joined with org names
```

## SQL conventions

Every source query mirrors the `dbt/models/03-marts/` style used to build the marts they read:
- lowercase keywords, 4-space indent, trailing commas
- `where true and ...` scaffolding for stable diffs
- CTE prefixes: `flt__` (filter), `agg__` (aggregate), `dim__` (identity carry-through), `bkt__` (bucketing)
- File names as `<domain>__<purpose>.sql`, double-underscore mirrors `mart_snp_fact__*`

## Windows

- **KPI cards.** Trailing 30-day window, upper-bounded at `today - 1` to exclude the current day (its partition hasn't been materialized yet). Comparison columns pull the preceding 30-day window.
- **Trend charts.** Trailing 90-day window, same upper bound.
- **Weekly rollup.** 180-day window on the pre-aggregated weekly marts.
- **Leaderboards.** Trailing 30-day window on the daily marts, matching the KPI cards. `active_days` counts how many of those 30 days each row saw any activity, which sidesteps the double-count problem of summing daily `unique_users_count`.

## Local setup

One-time:

```bash
# 1) Authenticate as yourself (ADC)
gcloud auth application-default login
gcloud config set project joshua-data
gcloud auth application-default set-quota-project joshua-data

# 2) Node deps
cd evidence
npm install
```

Verify by running the local dev server:

```bash
npm run sources     # queries BigQuery, writes sources/bigquery/*.parquet
npm run dev         # http://localhost:3000
```

`npm run dev` also runs `evidence sources` on demand when you edit a source file, so you rarely need to run `sources` manually after the first pass.

## Producing a production build locally

```bash
npm run build
npx serve build     # serves at http://localhost:3000, respects basePath
```

Open <http://localhost:3000/project-gharchive-elt/evidence/>.

## `basePath` behaviour

`evidence.config.yaml` sets `deployment.basePath: /project-gharchive-elt/evidence` so asset URLs and SvelteKit routing work correctly under the GitHub Pages sub-path. `npm run dev` reads the same config and mounts the app under that sub-path locally too, so visit `http://localhost:3000/project-gharchive-elt/evidence/` (not `/`). If you prefer serving at root during development, set `EVIDENCE_DEPLOYMENT__BASE_PATH=""` before `npm run dev`.

## Adding a page

1. Add or edit a query file under `sources/bigquery/*.sql`. Each file becomes a queryable table named `bigquery.<file_stem>`.
2. Add a Markdown page under `pages/`. Reference the query with a fenced SQL block:
   ~~~markdown
   ```sql my_result
   select * from bigquery.my_query
   ```
   <LineChart data={my_result} x=day y=events/>
   ~~~
3. Every mart is partitioned with `require_partition_filter: true`, so **every query must include a predicate on the partition column** (`created_date`, `opened_date`, or `review_submitted_date`). BigQuery will otherwise reject the query.
4. Keep inline `select * from bigquery.<query>` blocks only for wiring data into a page, and put the actual transformation logic in `sources/bigquery/*.sql` so it stays discoverable and testable.

## Deployment

The `evidence-build.yml` workflow performs the following whenever it runs:

1. Checks out the repo and sets up Node 20.
2. `google-github-actions/auth@v3` exchanges the WIF token for ADC.
3. `npm ci` installs pinned dependencies.
4. `npm run sources` queries BigQuery and materializes Parquet under `sources/bigquery/`.
5. `npm run build` compiles the static site to `evidence/build/`.
6. A guard step greps `evidence/build/` for anything that looks like an SA key and fails the job if it finds one.
7. Checks out `joshua-data/joshua-data.github.io` using the `DBT_DOCS_DEPLOY_TOKEN` PAT (reused from the dbt-docs workflow; scope already covers the docs repo).
8. Replaces `project-gharchive-elt/evidence/` in the docs repo with the fresh build and pushes.

The workflow fires on three triggers:
- `workflow_run` after every successful `dbt-run.yml` on `main`, for the chained daily refresh.
- `push` to `main` touching `evidence/**`, for Evidence site code changes.
- `workflow_dispatch`, for manual re-runs when debugging.

GitHub Pages rebuilds the docs repo within a minute or two, and the new Evidence site is live at the published URL.
