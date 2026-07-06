# dbt

**What this is:** the dbt project that transforms the raw GitHub Archive event stream into curated facts and dimensions under the `dw` BigQuery dataset. Lives inside the monorepo so infra (Terraform), ingest, and transformation evolve together.

**How it runs:**
- **Daily batch** — GitHub Actions workflow [`dbt-run.yml`](../.github/workflows/dbt-run.yml) fires at `17 6 * * *` UTC. It impersonates the `gharchive-dbt-runner` service account via Workload Identity Federation (no keys) and runs `dbt build --target prod`. On every push to `main` that touches `dbt/**`, the workflow additionally regenerates docs and pushes them to the [`joshua-data.github.io`](https://github.com/joshua-data/joshua-data.github.io) repo under `project-gharchive-elt/dbt-docs/`.
- **Local development & backfill** — you run as yourself via `gcloud auth application-default login`. No service account keys, no impersonation.

**Where docs live:** <https://joshua-data.github.io/project-gharchive-elt/dbt-docs/> (refreshed on every push to `main` that touches `dbt/**`).

> ↩ Back to [project overview](../README.md). For raw layer infra → [`../terraform/README.md`](../terraform/README.md). For raw layer pipeline → [`../ingest/README.md`](../ingest/README.md).

## Conventions

- **Raw source:** the `gharchive` source declared in [`models/sources.yml`](models/sources.yml). Reference via `{{ source('gharchive', 'events') }}` — don't hard-code the underlying dataset / table name.
- **Curated dataset:** `dw` (Terraform-provisioned, `asia-northeast3`).
- **Local dev dataset:** `dw_dev` (Terraform-provisioned alongside `dw` — see [`../terraform/bigquery.tf`](../terraform/bigquery.tf); override with `DBT_DEV_DATASET`).
- **Location:** all datasets are in `asia-northeast3`. dbt-bigquery uses the `location` from `profiles.yml`.
- **Profiles:** `DBT_PROFILES_DIR=.` (run from this directory) makes dbt read the in-repo `profiles.yml` instead of `~/.dbt/profiles.yml`. All dbt state is self-contained under `/dbt`.
- **Model layout:** `models/` is organized into numbered sub-folders (`01-stg/`, `02-core/`, …) so the build order is obvious at a glance. Default materialization is `view`; layers that need it override per-model in YAML.
- **Column docs:** shared `{% docs %}` blocks live under [`docs/`](docs/) and are referenced from model YAMLs as `'{{ doc("column_name") }}'`. `docs-paths: ["docs"]` in `dbt_project.yml` wires this up.
- **Column naming:** consistent suffixes across dimensions — `*_id` = GitHub's numeric ID (durable join key), `*_name` = lowercased canonical handle (case-insensitive join key), `*_display_name` = case-preserved display form, `*_object_url` = REST API URL, `*_image_url` = avatar URL.
- **Variables (batch window):** three vars define the active batch window. Resolution precedence (empty string = not-set):
    1. `batch_start_date` + `batch_end_date` (both required together) → closed date range. Primarily for local range backfills.
    2. `batch_date` → 1-day lookback window, `between (batch_date - 1 day) and batch_date`. This is what CI passes (yesterday UTC); the lookback covers partitions that the ingest layer landed late via its `CATCHUP_HOURS` retry window.
    3. none set → compile error. There is no implicit default — we'd rather fail loud than silently scan everything against `require_partition_filter: true` tables.

  Don't read these vars directly in models — use the batch-window macros below, which centralize the precedence and validation.

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

Three macros centralize the batch window: two predicate helpers for **model** SQL (`batch_filter`, `reverse_batch_filter`) and one dbt override for **test** `where` configs (`get_where_subquery`). All three consume the same `batch_*` vars described under *Conventions* so the model build and the assertions that follow it cover the same partitions.

### `batch_filter` — closed-range predicate for model SQL

Emits a BETWEEN predicate over a date column.

```sql
{{ batch_filter(date_col='dt', start_date=none, end_date=none, interval='day') }}
```

If both `start_date` and `end_date` are passed, they're used as-is (pure mode — no var lookup). Otherwise the window is inherited from dbt vars, in precedence:

1. `batch_start_date` + `batch_end_date` (both set) → closed range
2. `batch_date` set → `between (batch_date - 1 day) and batch_date` (1-day lookback; mirrors the ingest layer's catchup window so partitions that landed late are re-materialized)
3. none set → raises a compile error (prevents accidental full scans against `require_partition_filter: true` tables)

`interval` snaps the lower bound back to the start of the enclosing period — passed straight through to BigQuery `DATE_TRUNC`, so any unit `DATE_TRUNC` accepts works (`day` is the default no-op; `week`, `week(<weekday>)`, `month`, `quarter`, `year` all valid). The upper bound is left as-is — this widens the scan to a period-to-date (WTD / MTD / QTD) window without pulling in future dates that haven't materialized yet.

Usage:

```sql
-- default: inherit from vars, day-grain (no snap)
where {{ batch_filter('dt') }}

-- explicit: pure function, ignores vars
where {{ batch_filter('dt', '2026-05-01', '2026-05-07') }}

-- weekly snapshot: snap lower bound back to enclosing Sunday week start
where {{ batch_filter('date', interval='week(sunday)') }}

-- monthly snapshot: snap lower bound back to the 1st of the enclosing month
where {{ batch_filter('date', interval='month') }}
```

### `reverse_batch_filter` — "before this batch" predicate for baselines

Emits an open-ended `date_col < <lower bound>` predicate — the complement of `batch_filter`. Used when a model needs to read everything *strictly prior* to the current batch window: seeding an accumulating-snapshot fact from historical partitions, computing prior-period baselines for change detection, etc.

```sql
{{ reverse_batch_filter(date_col='dt', start_date=none, interval='day') }}
```

Bound resolution mirrors `batch_filter` (`start_date` arg → `batch_start_date` var → `batch_date` var with 1-day lookback → compile error). `interval` snaps the bound to the enclosing period start so the predicate cleanly excludes the current period-to-date window.

```sql
-- everything before the current batch window's lower bound
where {{ reverse_batch_filter('dt') }}

-- weekly baseline: everything before this week's Sunday start
where {{ reverse_batch_filter('date', interval='week(sunday)') }}
```

### `get_where_subquery` — batch-aware test predicates

Overrides dbt's built-in `get_where_subquery` so that any `__batch_start_date__` / `__batch_end_date__` placeholder inside a test's `where` config is rewritten to a `date 'YYYY-MM-DD'` literal at compile time. Lets test YAML scope assertions to the batch window without embedding `{{ var('...') }}` (which dbt doesn't render inside `where` configs). Falls back to dbt's default behavior when no placeholder is present.

```yaml
# in a schema.yml test config
tests:
  - not_null:
      column_name: repo_id
      config:
        where: "dt between __batch_start_date__ and __batch_end_date__"
```

Value resolution mirrors `batch_filter` (`batch_start_date` + `batch_end_date` → `batch_date` → error). Note: unlike `batch_filter`, **no 1-day lookback is applied** on the `batch_date` path — the lookback happens once at the model layer, so re-applying it in tests would double-count.

## Backfill

For a single date:

```bash
DBT_PROFILES_DIR=. dbt build --target dev \
  --vars '{batch_date: "2026-05-01"}'
```

For a date range, set both range vars (single `dbt build`, single union window):

```bash
DBT_PROFILES_DIR=. dbt build --target dev \
  --vars '{batch_start_date: "2026-05-01", batch_end_date: "2026-05-07"}'
```

Or, for incremental models that need per-day materialization, loop in a shell:

```bash
for d in $(seq 0 6); do
  RD=$(date -u -v-${d}d +%Y-%m-%d)   # macOS; on Linux: date -u -d "$d days ago" +%F
  DBT_PROFILES_DIR=. dbt build --target dev \
    --vars "{batch_date: '$RD'}"
done
```

Prod backfills via CI are not directly supported — `dbt-run.yml` is triggered only by `schedule` (daily) and by `push` to `main` on `dbt/**` (excluding `dbt/README.md`) and the workflow file itself. Both of those always resolve `batch_date` to yesterday UTC, so they can't target an arbitrary past day. Local prod runs also require `bigquery.dataEditor` on `dw`, which only `gharchive-dbt-runner` has by default. To backfill a specific historical date in prod, temporarily add a `workflow_dispatch` trigger (with a `batch_date` input) to `dbt-run.yml`, or run locally while impersonating `gharchive-dbt-runner`.

## CI/CD

| When | Workflow | What it does |
|---|---|---|
| `17 6 * * *` UTC | `.github/workflows/dbt-run.yml` (`schedule`) | `dbt debug` → cache `dbt_packages/` → `dbt deps` → `dbt source freshness` (warn-only, won't block) → resolve `batch_date` (yesterday UTC) → `dbt build --target prod --vars '{batch_date: ...}'` |
| `push` → `main` on `dbt/**` (excluding `dbt/README.md`) or the workflow file | `.github/workflows/dbt-run.yml` (`push`) | Same build steps as the scheduled run, plus `dbt docs generate` + publish docs to `joshua-data.github.io/project-gharchive-elt/dbt-docs/`. Every merge that touches `dbt/` therefore re-runs prod once and refreshes docs. |
| Manual | *(not configured)* | `workflow_dispatch` is not wired up — add it temporarily for historical backfills |
| PR | *(none — by design)* | dbt CI is not run on PRs; the WIF attribute condition refuses non-`main` refs |

Both triggers (schedule and push-to-`main`) run against `main`, so they satisfy the WIF condition `assertion.ref == "refs/heads/main"`. The `dbt-runner` SA is impersonated using the same WIF pool as `terraform.yml` / `ingest-deploy.yml`.

## Required GitHub secrets (in addition to the existing four)

| Name | What | Where to get it |
|---|---|---|
| `DBT_RUNNER_SA_EMAIL` | `gharchive-dbt-runner@joshua-data.iam.gserviceaccount.com` | `terraform output dbt_runner_sa_email` |
| `DBT_DOCS_DEPLOY_TOKEN` | Fine-grained PAT with `Contents: Read+Write` on `joshua-data/joshua-data.github.io` only | GitHub → Settings → Developer settings → Personal access tokens → Fine-grained |
