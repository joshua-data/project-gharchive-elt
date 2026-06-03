# project-gharchive-elt

**What this is:** an hourly **ELT pipeline** that ingests [GitHub Archive](https://www.gharchive.org/) events into Google Cloud, plus a **dbt transformation layer** that builds curated tables on top. Raw events land as Hive-partitioned Parquet in GCS (exposed via a BigQuery external table); dbt builds curated models into a separate `dw` dataset daily.

**How it runs:**
- **Ingest (hourly):** a Python container executes as a **Cloud Run Job**, triggered every hour by **Cloud Scheduler**. Built and deployed by GitHub Actions on every push to `main`.
- **Transform (daily):** GitHub Actions schedule (`0 6 * * *` UTC) runs `dbt build` against BigQuery, then publishes generated dbt docs to the [`joshua-data.github.io`](https://github.com/joshua-data/joshua-data.github.io) repo.

**How it's managed:** all GCP infrastructure (bucket, datasets, table, Cloud Run Job, scheduler, service accounts, IAM, WIF) lives in one Terraform root module under `terraform/`. All three workflows (terraform, ingest-deploy, dbt-run) authenticate via **Workload Identity Federation** — no service-account keys exist anywhere in the repo or in GitHub.

**Where to start:** pipeline code → [`ingest/`](ingest/README.md). Transformation models → [`dbt/`](dbt/README.md). Infrastructure → [`terraform/`](terraform/README.md). Hosted dbt docs → <https://joshua-data.github.io/project-gharchive-elt/dbt-docs/>.

## Architecture

```mermaid
flowchart LR
    subgraph GH["🗂️ GitHub"]
        direction TB
        REPO["📝 Repository<br/><i>main branch</i>"]
        GHA["⚙️ GitHub Actions<br/><i>WIF, no keys</i>"]
    end

    subgraph GCP["☁️ Google Cloud Platform"]
        direction TB
        AR["📦 Artifact Registry<br/><i>gharchive</i>"]
        SCH["📅 Cloud Scheduler<br/><i>30 * * * *</i>"]
        JOB["⚡ Cloud Run Job<br/><i>gharchive</i>"]
        GCS["🗄️ GCS bucket<br/><i>events/dt=…/hr=…/*.parquet</i>"]
        BQ["📊 BigQuery external table<br/><i>raw__gharchive.ext__events</i>"]
        DW["📈 BigQuery dataset<br/><i>dw (curated by dbt)</i>"]
    end

    EXT["📥 data.gharchive.org<br/><i>.json.gz</i>"]
    DOCS["📖 joshua-data.github.io<br/><i>project-gharchive-elt/dbt-docs/</i>"]

    REPO --> GHA
    GHA -->|"build &amp; push image"| AR
    GHA -->|"terraform apply"| GCP
    GHA -->|"dbt build (daily 06:00 UTC)"| BQ
    GHA -->|"publish docs"| DOCS
    AR -->|"image"| JOB
    SCH -->|"POST :run"| JOB
    JOB -->|"GET .json.gz"| EXT
    JOB -->|"write Parquet + _SUCCESS"| GCS
    GCS -->|"external table source"| BQ
    BQ -->|"dbt transform"| DW

    classDef primary   fill:#667eea,stroke:#764ba2,color:#fff,stroke-width:3px
    classDef secondary fill:#4facfe,stroke:#00f2fe,color:#fff,stroke-width:2px
    classDef success   fill:#38ef7d,stroke:#11998e,color:#1e293b,stroke-width:3px
    classDef warning   fill:#fef3c7,stroke:#f59e0b,color:#78350f,stroke-width:2px
    classDef neutral   fill:#f8fafc,stroke:#cbd5e1,color:#1e293b,stroke-width:1px

    class JOB,SCH primary
    class GCS secondary
    class BQ,DW success
    class AR warning
    class REPO,GHA,EXT,DOCS neutral

    style GH fill:#94a3b815,stroke:#94a3b8,stroke-width:2px
    style GCP fill:#667eea15,stroke:#667eea,stroke-width:2px
```

## Repository layout

| Path | What's there |
|---|---|
| [`ingest/`](ingest/README.md) | Python 3.12 container — downloads the hourly `.json.gz` from gharchive.org, transforms to a stable schema, writes Parquet to GCS. **Start here if you're touching pipeline code.** |
| [`dbt/`](dbt/README.md) | dbt project (dbt-core / dbt-bigquery `1.11`) — transforms `raw__gharchive.ext__events` into curated tables under `dw`. Profiles point at BigQuery via OAuth (ADC locally, WIF impersonation in CI). **Start here if you're writing transformation SQL.** |
| [`terraform/`](terraform/README.md) | All GCP infrastructure as code — bucket, BigQuery datasets (`raw__gharchive`, `dw`, `dw_dev`), external table, Cloud Run Job, Scheduler, IAM, WIF. **Start here if you're touching infra.** |
| `.github/workflows/` | CI/CD — `terraform.yml` plans + applies on push to `main`; `ingest-deploy.yml` builds/pushes the image and updates the Cloud Run Job; `dbt-run.yml` runs daily `dbt build` and publishes docs to `joshua-data.github.io`. |

## End-to-end flow

1. **Cloud Scheduler** fires at `30 * * * *` UTC and POSTs to the Cloud Run Job admin API, authenticating as the `gharchive-invoker` service account.
2. **Cloud Run Job** starts the container as `gharchive-runner`. The job resolves which hours to process from `LAG_HOURS` / `CATCHUP_HOURS` (defaulting to "the hour that finished `LAG_HOURS` ago, plus the previous `CATCHUP_HOURS` for gap recovery").
3. For each target hour, the container checks for a `_SUCCESS` marker in GCS and skips if present (idempotent re-runs).
4. Otherwise it downloads `https://data.gharchive.org/{YYYY-MM-DD-H}.json.gz` with a retry loop (404/5xx/network → retry up to 5×, backoff capped at 60s).
5. JSON-Lines are streamed into a stable Parquet schema (Snappy-compressed) and uploaded to `gs://{project}-gharchive/events/dt=YYYY-MM-DD/hr=HH/YYYY-MM-DD-HH.parquet`, followed by an empty `_SUCCESS` sibling.
6. The **BigQuery external table** (`raw__gharchive.ext__events`) is configured with Hive partitioning AUTO, so new partitions become queryable immediately — no metadata refresh needed.
7. **dbt** (`dbt-run.yml`, daily `0 6 * * *` UTC) impersonates `gharchive-dbt-runner` via WIF, runs `dbt build --target prod --vars '{batch_date: <yesterday UTC>}'` against BigQuery (materializes into `dw`), generates docs, and pushes them to `joshua-data.github.io/project-gharchive-elt/dbt-docs/`.

## Tech stack

- **Runtime:** Python 3.12 (`httpx`, `pyarrow`, `pydantic-settings`, `google-cloud-storage`)
- **Container:** Docker, base `python:3.12-slim`, non-root user
- **Orchestration:** Cloud Run Job + Cloud Scheduler (ingest); GitHub Actions schedule (dbt)
- **Storage:** GCS (raw Parquet) → BigQuery external table (`raw__gharchive.ext__events`) → BigQuery curated (`dw`)
- **Transformation:** dbt-core / dbt-bigquery `1.11`, OAuth (ADC + WIF impersonation)
- **IaC:** Terraform `>= 1.6`, Google provider `~> 5.40`, state in GCS
- **CI/CD:** GitHub Actions with Workload Identity Federation (no SA keys)
- **Quality:** `ruff` for Python lint, `terraform fmt -check` + `validate` on every PR

## Getting started

There's no shortcut: the infra has to exist before the ingest job can run, and ingest needs to produce data before dbt has anything to transform. Do them in order:

1. **Provision infra** → [`terraform/README.md`](terraform/README.md) (bootstrap state bucket, `terraform apply`, copy outputs to GitHub secrets including the new `DBT_RUNNER_SA_EMAIL`).
2. **Deploy ingest** → push to `main`; `ingest-deploy.yml` builds the image and points the Cloud Run Job at it. Wait for at least one hourly run to land Parquet in GCS.
3. **Develop or backfill locally** → [`ingest/README.md`](ingest/README.md) (Python venv + ADC, or the `scripts/backfill.sh` Docker wrapper).
4. **Write dbt models** → [`dbt/README.md`](dbt/README.md) (local: `gcloud auth application-default login` + `dbt build --target dev`). Add the `DBT_DOCS_DEPLOY_TOKEN` secret (PAT for `joshua-data.github.io`) before the scheduled `dbt-run.yml` can publish docs.
