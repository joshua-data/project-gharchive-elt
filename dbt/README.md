# dbt

**What this is:** the dbt project that transforms `raw__gharchive.ext__events` into curated tables under the `dw` BigQuery dataset. Lives inside the monorepo so infra (Terraform), ingest, and transformation evolve together.

**How it runs:**
- **Daily batch** — GitHub Actions workflow [`dbt-run.yml`](../.github/workflows/dbt-run.yml) fires at `0 6 * * *` UTC. It impersonates the `gharchive-dbt-runner` service account via Workload Identity Federation (no keys), runs `dbt build --target prod`, regenerates docs, and pushes them to the [`joshua-data.github.io`](https://github.com/joshua-data/joshua-data.github.io) repo under `project-gharchive-elt/dbt-docs/`.
- **Local development & backfill** — you run as yourself via `gcloud auth application-default login`. No service account keys, no impersonation.

**Where docs live:** <https://joshua-data.github.io/project-gharchive-elt/dbt-docs/> (updated on every successful prod run).

> ↩ Back to [project overview](../README.md). For raw layer infra → [`../terraform/README.md`](../terraform/README.md). For raw layer pipeline → [`../ingest/README.md`](../ingest/README.md).

## Layout

```
dbt/
├── dbt_project.yml          # project config, default materialization, batch vars
├── profiles.yml             # OAuth (ADC) — no secrets, committed
├── packages.yml             # dbt_utils
├── requirements.txt         # dbt-core 1.11, dbt-bigquery 1.11
├── models/
│   ├── sources.yml          # raw__gharchive.ext__events declared as source
│   └── 01-stg/              # staging layer (numbered prefix = build order)
│       └── stg_fact__events.{sql,yml}
├── macros/
│   ├── batch_filter.{sql,yml}        # batch-window predicate macro (see below)
│   └── get_where_subquery.{sql,yml}  # override of dbt's built-in — resolves __batch_*_date__ placeholders in test `where` configs
├── docs/
│   └── columns.md           # shared `{% docs %}` blocks reused across model YAMLs
├── seeds/ snapshots/ tests/ analyses/
└── target/  dbt_packages/  logs/   ← gitignored
```

`DBT_PROFILES_DIR=.` (set automatically when you run from this directory) makes dbt read the in-repo `profiles.yml` instead of `~/.dbt/profiles.yml`. We keep all dbt state self-contained under `/dbt`.

## Conventions

- **Raw source:** `raw__gharchive.ext__events`, declared in [`models/sources.yml`](models/sources.yml) under the `gharchive` source. Reference via `{{ source('gharchive', 'events') }}`.
- **Curated dataset:** `dw` (Terraform-provisioned, `asia-northeast3`).
- **Local dev dataset:** `dw_dev` (Terraform-provisioned alongside `dw` — see [`../terraform/bigquery.tf`](../terraform/bigquery.tf); override with `DBT_DEV_DATASET`).
- **Location:** all datasets are in `asia-northeast3`. dbt-bigquery uses the `location` from `profiles.yml`.
- **Model layout:** `models/` is organized into numbered sub-folders (`01-stg/`, `02-…/`, …) so the layer order is obvious at a glance. Default materialization is `view`; layers that need it (e.g. staging) override per-model in YAML.
- **Column docs:** shared `{% docs %}` blocks live in [`docs/columns.md`](docs/columns.md) and are referenced from model YAMLs as `'{{ doc("column_name") }}'`. `docs-paths: ["docs"]` in `dbt_project.yml` is what wires this up.
- **Variables (batch window):** three vars define the active batch window. Resolution precedence (empty string = not-set):
    1. `batch_start_date` + `batch_end_date` (both required together) → closed date range. Primarily for local range backfills.
    2. `batch_date` → 1-day lookback window, `between (batch_date - 1 day) and batch_date`. This is what CI passes (yesterday UTC at `0 6 * * *`); the lookback covers partitions that the ingest layer landed late via its `CATCHUP_HOURS` retry window.
    3. none set → compile error. There is no implicit default — we'd rather fail loud than silently scan everything against `require_partition_filter: true` tables.

  Don't read these vars directly in models — use the batch-window macros below, which centralize the precedence and validation.

## Models

| Layer | Folder | Models |
|---|---|---|
| Staging | `models/01-stg/` | `stg_fact__events` |

**`stg_fact__events`** — one row per public GitHub event from `raw__gharchive.ext__events`. Flattens the `actor` / `repo` / `org` JSON blobs into typed scalar columns, parses `payload` into a native `JSON` value (intentionally left unflattened — its shape varies by `event_name`), and dedupes across re-ingests with `row_number() over (partition by id order by ingested_at desc) = 1`.

- Materialization: `incremental` (`insert_overwrite`), partitioned by `created_date` (day), clustered by `(event_name, repo_id)`, `require_partition_filter: true`.
- Batch window comes from the `batch_filter` macro — see below.

Column naming follows a small set of suffixes that hold across all dimensions: `*_id` = GitHub's numeric ID (durable join key), `*_name` = lowercased canonical handle (case-insensitive join key), `*_display_name` = case-preserved display form, `*_object_url` = REST API URL, `*_image_url` = avatar URL.

## Local setup

One-time:

```bash
# 1) Authenticate as yourself (ADC)
gcloud auth application-default login
gcloud config set project joshua-data
gcloud auth application-default set-quota-project joshua-data

# 2) Python env + dbt
cd dbt
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

Verify the connection:

```bash
DBT_PROFILES_DIR=. dbt debug --target dev
```

You should see six green `OK` lines, including `Connection test: OK`. If `Connection test: FAIL` with `403`/`Permission denied`, check that your account has BigQuery roles on `joshua-data` and that `application-default` quota project is set.

## Day-to-day commands

```bash
# Install dbt packages (run after editing packages.yml)
DBT_PROFILES_DIR=. dbt deps

# Parse-only (fast, offline)
DBT_PROFILES_DIR=. dbt parse

# Run + test against dev dataset (dw_dev)
DBT_PROFILES_DIR=. dbt build --target dev

# Only your model + downstream
DBT_PROFILES_DIR=. dbt build --target dev --select +my_model+

# Local docs server
DBT_PROFILES_DIR=. dbt docs generate --target dev
DBT_PROFILES_DIR=. dbt docs serve --port 8081
```

> Tip: drop `DBT_PROFILES_DIR=` into a `.envrc` (direnv) so you stop typing it.

## Batch window macros

Two macros centralize the batch window, one for **models** and one for **tests**. Both consume the same `batch_*` vars described under *Conventions* so the model build and the assertions that follow it cover the same partitions.

### `batch_filter` — predicate for model SQL

`macros/batch_filter.sql` emits a BETWEEN predicate over a date column.

```sql
{{ batch_filter(date_col='dt', start_date=none, end_date=none) }}
```

If both `start_date` and `end_date` are passed, they're used as-is (pure mode — no var lookup). Otherwise the window is inherited from dbt vars, in precedence:

1. `batch_start_date` + `batch_end_date` (both set) → closed range
2. `batch_date` set → `between (batch_date - 1 day) and batch_date` (1-day lookback; mirrors the ingest layer's catchup window so partitions that landed late are re-materialized)
3. none set → raises a compile error (prevents accidental full scans against `require_partition_filter: true` tables)

Usage:

```sql
-- default: inherit from vars
where {{ batch_filter('dt') }}

-- explicit: pure function, ignores vars
where {{ batch_filter('dt', '2026-05-01', '2026-05-07') }}
```

Build anything more involved (rolling windows, calendar joins, lookback, etc.) on top of this directly in the model SQL — usually by resolving the dates once at the top of the model and passing them to `batch_filter` explicitly.

### `get_where_subquery` — placeholder rewriting for test `where` configs

`macros/get_where_subquery.sql` overrides dbt's built-in macro of the same name. Its job is to scope **tests** (uniqueness, not-null, expression checks, etc.) to the same batch window the model just materialized — without having to embed `{% raw %}{{ var('...') }}{% endraw %}` inside test YAML.

Write tests using the literal placeholders `__batch_start_date__` / `__batch_end_date__`:

```yaml
data_tests:
  - not_null:
      config:
        where: "created_date between __batch_start_date__ and __batch_end_date__"
```

At compile time the override calls the `replace_batch_dates` helper, which substitutes the placeholders with `date 'YYYY-MM-DD'` literals resolved from the same `batch_start_date` / `batch_end_date` / `batch_date` vars. Unlike `batch_filter`, the helper does **not** apply a 1-day lookback to `batch_date`; the lookback already lives in the model's `batch_filter` call, so re-applying it here would widen the test window past the partitions that were actually rewritten. Missing vars raise a compile error rather than leaking a literal `__batch_start_date__` token into the SQL.

If a `where` config doesn't contain either placeholder, the override falls back to dbt's built-in behavior (the string is passed through verbatim).

## Backfill

For a single date:

```bash
DBT_PROFILES_DIR=. dbt build --target dev \
  --select tag:daily \
  --vars '{batch_date: "2026-05-01"}'
```

For a date range, set both range vars (single `dbt build`, single union window):

```bash
DBT_PROFILES_DIR=. dbt build --target dev \
  --select tag:daily \
  --vars '{batch_start_date: "2026-05-01", batch_end_date: "2026-05-07"}'
```

Or, for incremental models that need per-day materialization, loop in a shell:

```bash
for d in $(seq 0 6); do
  RD=$(date -u -v-${d}d +%Y-%m-%d)   # macOS; on Linux: date -u -d "$d days ago" +%F
  DBT_PROFILES_DIR=. dbt build --target dev \
    --select tag:daily \
    --vars "{batch_date: '$RD'}"
done
```

Prod backfills via CI are not directly supported — `dbt-run.yml` is triggered only by `schedule` (daily) and by `push` to `main` on `dbt/**` (excluding `dbt/README.md`) and the workflow file itself. Both of those always resolve `batch_date` to yesterday UTC, so they can't target an arbitrary past day. Local prod runs also require `bigquery.dataEditor` on `dw`, which only `gharchive-dbt-runner` has by default. To backfill a specific historical date in prod, temporarily add a `workflow_dispatch` trigger (with a `batch_date` input) to `dbt-run.yml`, or run locally while impersonating `gharchive-dbt-runner`.

## CI/CD

| When | Workflow | What it does |
|---|---|---|
| `0 6 * * *` UTC | `.github/workflows/dbt-run.yml` (`schedule`) | `dbt debug` → cache `dbt_packages/` → `dbt deps` → resolve `batch_date` (yesterday UTC) → `dbt build --target prod --vars '{batch_date: ...}'` → `dbt docs generate` → push docs to `joshua-data.github.io/project-gharchive-elt/dbt-docs/` |
| `push` → `main` on `dbt/**` (excluding `dbt/README.md`) or the workflow file | `.github/workflows/dbt-run.yml` (`push`) | Same steps as the scheduled run, with `batch_date` again resolved to yesterday UTC. Every merge that touches `dbt/` therefore re-runs prod once. |
| Manual | *(not configured)* | `workflow_dispatch` is not wired up — add it temporarily for historical backfills |
| PR | *(none — by design)* | dbt CI is not run on PRs; the WIF attribute condition refuses non-`main` refs |

Both triggers (schedule and push-to-`main`) run against `main`, so they satisfy the WIF condition `assertion.ref == "refs/heads/main"`. The `dbt-runner` SA is impersonated using the same WIF pool as `terraform.yml` / `ingest-deploy.yml`.

## Required GitHub secrets (in addition to the existing four)

| Name | What | Where to get it |
|---|---|---|
| `DBT_RUNNER_SA_EMAIL` | `gharchive-dbt-runner@joshua-data.iam.gserviceaccount.com` | `terraform output dbt_runner_sa_email` |
| `DBT_DOCS_DEPLOY_TOKEN` | Fine-grained PAT with `Contents: Read+Write` on `joshua-data/joshua-data.github.io` only | GitHub → Settings → Developer settings → Personal access tokens → Fine-grained |
