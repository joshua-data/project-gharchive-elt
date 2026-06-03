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
├── dbt_project.yml          # project config, materialization defaults
├── profiles.yml             # OAuth (ADC) — no secrets, committed
├── packages.yml             # dbt_utils
├── requirements.txt         # dbt-core 1.11, dbt-bigquery 1.11
├── models/                  # you write SQL here
├── seeds/ macros/ snapshots/ tests/ analyses/
└── target/  dbt_packages/  logs/   ← gitignored
```

`DBT_PROFILES_DIR=.` (set automatically when you run from this directory) makes dbt read the in-repo `profiles.yml` instead of `~/.dbt/profiles.yml`. We keep all dbt state self-contained under `/dbt`.

## Conventions

- **Raw source:** `raw__gharchive.ext__events` (BigQuery external table over Hive-partitioned Parquet in GCS).
- **Curated dataset:** `dw` (Terraform-provisioned, `asia-northeast3`).
- **Local dev dataset:** `dw_dev` (auto-created on first run; override with `DBT_DEV_DATASET`).
- **Location:** all datasets are in `asia-northeast3`. dbt-bigquery uses the `location` from `profiles.yml`.
- **Variables:** `batch_date` is reserved for incremental models (`{{ var('batch_date') }}`) and conventionally refers to **the day before the run** (i.e., yesterday UTC relative to schedule start). Default empty → models should treat empty as "yesterday UTC".

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

## Backfill

For a single date:

```bash
DBT_PROFILES_DIR=. dbt build --target dev \
  --select tag:daily \
  --vars '{batch_date: "2026-05-01"}'
```

For a date range, loop in a shell — `batch_date` is a single-day var by convention:

```bash
for d in $(seq 0 6); do
  RD=$(date -u -v-${d}d +%Y-%m-%d)   # macOS; on Linux: date -u -d "$d days ago" +%F
  DBT_PROFILES_DIR=. dbt build --target dev \
    --select tag:daily \
    --vars "{batch_date: '$RD'}"
done
```

Prod backfills (`--target prod` against `dw`) are not supported from CI — `dbt-run.yml` only exposes a `schedule` trigger. Local prod runs also require `bigquery.dataEditor` on `dw`, which only `gharchive-dbt-runner` has by default. To backfill prod, temporarily re-add a `workflow_dispatch` trigger to `dbt-run.yml`.

## CI/CD

| When | Workflow | What it does |
|---|---|---|
| `0 6 * * *` UTC | `.github/workflows/dbt-run.yml` (`schedule`) | `dbt deps` → resolve `batch_date` (yesterday UTC) → `dbt build --target prod --vars '{batch_date: ...}'` → `dbt docs generate` → push docs to `joshua-data.github.io/project-gharchive-elt/dbt-docs/` |
| Manual | *(not configured)* | `workflow_dispatch` is not wired up; the workflow only fires on schedule |
| PR | *(none — by design)* | dbt CI is not run on PRs; the WIF attribute condition refuses non-`main` refs |

The schedule trigger always runs against `main` (GitHub's default), so it satisfies the WIF condition `assertion.ref == "refs/heads/main"`. The `dbt-runner` SA is impersonated using the same WIF pool as `terraform.yml` / `ingest-deploy.yml`.

## Required GitHub secrets (in addition to the existing four)

| Name | What | Where to get it |
|---|---|---|
| `DBT_RUNNER_SA_EMAIL` | `gharchive-dbt-runner@joshua-data.iam.gserviceaccount.com` | `terraform output dbt_runner_sa_email` |
| `DBT_DOCS_DEPLOY_TOKEN` | Fine-grained PAT with `Contents: Read+Write` on `joshua-data/joshua-data.github.io` only | GitHub → Settings → Developer settings → Personal access tokens → Fine-grained |
