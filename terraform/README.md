# terraform

**What this is:** the single Terraform root module that provisions *every* piece of GCP infrastructure this project depends on — no submodules, no workspaces. If a resource (bucket, dataset, table, Cloud Run Job, scheduler, service account, IAM binding, Artifact Registry repo, WIF pool / provider) exists in our GCP project, it was created here.

**What you get out of an `apply`:** a Cloud Scheduler → Cloud Run Job → GCS → BigQuery pipeline, plus a Workload Identity Federation setup that lets GitHub Actions deploy and run Terraform itself with no service-account keys anywhere.

**Where to start reading:** `locals.tf` (names + lifecycle constants), `iam.tf` (the three service accounts and what they can do), `wif.tf` (how GitHub Actions impersonates `gharchive-ci-deployer`).

> ↩ Back to [project overview](../README.md). For the workload that runs *inside* the Cloud Run Job, see [`ingest/README.md`](../ingest/README.md).

## Resource map

```mermaid
flowchart LR
    subgraph GH["🗂️ GitHub repo<br/><i>main / PRs</i>"]
        GHA["⚙️ GitHub Actions"]
    end

    subgraph WIF["🔒 Workload Identity Federation"]
        direction TB
        POOL["🏗️ github-pool"]
        PROV["🔍 github-provider<br/><i>OIDC, repo+ref pinned</i>"]
    end

    subgraph SAS["👥 Service Accounts"]
        direction TB
        CID["💼 gharchive-ci-deployer<br/><i>run/scheduler/AR + IAM admin + BQ</i>"]
        RUN["🤖 gharchive-runner<br/><i>storage.objectCreator/Viewer</i>"]
        INV["🤖 gharchive-invoker<br/><i>run.invoker</i>"]
        DBT["🤖 gharchive-dbt-runner<br/><i>bigquery.dataEditor (dw / dw_dev)</i>"]
    end

    subgraph INFRA["☁️ GCP Resources"]
        direction TB
        AR["📦 Artifact Registry<br/><i>gharchive (Docker)</i>"]
        SCH["📅 Cloud Scheduler<br/><i>gharchive</i>"]
        JOB["⚡ Cloud Run Job<br/><i>gharchive</i>"]
    end

    subgraph DATA["📊 Data Layer"]
        direction TB
        GCS["🗄️ GCS bucket<br/><i>{project}-gharchive</i>"]
        BQDS[("📊 BigQuery dataset<br/><i>raw__gharchive</i>")]
        BQT["✅ External table<br/><i>ext__events</i>"]
        DW[("📈 BigQuery dataset<br/><i>dw (curated by dbt)</i>")]
        DWDEV[("🧪 BigQuery dataset<br/><i>dw_dev (local dbt dev)</i>")]
    end

    GHA --> POOL --> PROV
    PROV -->|"impersonates"| CID
    PROV -->|"impersonates"| DBT
    CID -->|"manages"| AR
    CID -->|"manages"| SCH
    CID -->|"manages"| JOB
    CID -->|"manages"| GCS
    CID -->|"manages"| BQDS
    CID -->|"manages"| DW
    CID -->|"manages"| DWDEV
    CID -.->|"impersonates (deploy)"| RUN

    SCH -->|"POST :run as"| INV
    INV --> JOB
    JOB -->|"runs as"| RUN
    JOB -->|"writes Parquet"| GCS
    GCS --> BQT
    BQT --> BQDS
    BQDS -->|"reads"| DBT
    DBT -->|"materializes"| DW

    classDef primary   fill:#667eea,stroke:#764ba2,color:#fff,stroke-width:3px
    classDef secondary fill:#4facfe,stroke:#00f2fe,color:#fff,stroke-width:2px
    classDef accent    fill:#f093fb,stroke:#f5576c,color:#fff,stroke-width:2px
    classDef alert     fill:#f5576c,stroke:#c0392b,color:#fff,stroke-width:3px
    classDef success   fill:#38ef7d,stroke:#11998e,color:#1e293b,stroke-width:3px
    classDef warning   fill:#fef3c7,stroke:#f59e0b,color:#78350f,stroke-width:2px
    classDef neutral   fill:#f8fafc,stroke:#cbd5e1,color:#1e293b,stroke-width:1px

    class JOB,SCH primary
    class GCS,RUN,INV secondary
    class CID,DBT alert
    class POOL,PROV warning
    class AR warning
    class BQT,BQDS,DW,DWDEV success
    class GHA neutral

    style GH fill:#94a3b815,stroke:#94a3b8,stroke-width:2px
    style WIF fill:#f5576c15,stroke:#f5576c,stroke-width:2px
    style SAS fill:#f093fb15,stroke:#f093fb,stroke-width:2px
    style INFRA fill:#667eea15,stroke:#667eea,stroke-width:2px
    style DATA fill:#38ef7d15,stroke:#38ef7d,stroke-width:2px
```

## What gets created, file by file

| File | Resources |
|---|---|
| `apis.tf` | Enables `cloudresourcemanager`, `iam`, `iamcredentials`, `sts`, `artifactregistry`, `run`, `cloudscheduler`, `storage`, `bigquery`. `disable_on_destroy = false` so `terraform destroy` doesn't turn off APIs other systems may rely on. |
| `gcs.tf` | Raw bucket `{project}-gharchive` — UBLA, public-access-prevention enforced, 7-day soft-delete window, and a lifecycle that promotes objects Standard → Nearline (30d) → Coldline (90d) → delete (180d). |
| `bigquery.tf` | Three datasets in `var.region`: `raw__gharchive` (raw layer) with external table `ext__events` over `gs://{bucket}/events/*.parquet` with `hive_partitioning_options.mode = "AUTO"` and `autodetect = true` (`deletion_protection = true`); `dw` (curated layer) where the scheduled dbt run materializes models; and `dw_dev` (local-development counterpart of `dw`, used by `profiles.yml`'s `dev` target). Note: at least one Parquet file must exist under the raw prefix before the external table is created — `autodetect` reads it to infer the schema. |
| `artifact_registry.tf` | Docker repo `gharchive` with two cleanup policies — keep the 10 most-recent versions, delete untagged images older than 24 h. |
| `cloud_run_job.tf` | Job `gharchive` running as the `gharchive-runner` SA, env vars `GCS_RAW_BUCKET` / `LAG_HOURS` / `CATCHUP_HOURS`, CPU/memory/timeout from variables, `max_retries = 1`. Uses Google's placeholder `cloudrun/container/job` image at bootstrap; `lifecycle.ignore_changes = [containers[0].image]` so the CI image tag updates don't get reverted on `terraform apply`. |
| `cloud_scheduler.tf` | Cron job that POSTs to the Job's `:run` admin endpoint as the `gharchive-invoker` SA. Retry policy: `retry_count = 0`, min/max backoff 30s/300s, `max_doublings = 3` — intentional (see *Operational notes*). |
| `iam.tf` | The four service accounts and their role bindings — see [Service accounts](#service-accounts) below for the design choices. |
| `wif.tf` | Pool `github-pool` + OIDC provider `github-provider`. Attribute mapping (`google.subject`, `attribute.repository`, `attribute.ref`, `attribute.actor`) and an **attribute condition** that hard-locks the provider to this repo on `main` only — PR branches cannot mint a token, so neither `gharchive-ci-deployer` nor `gharchive-dbt-runner` is reachable from any PR workflow. Both SAs grant `roles/iam.workloadIdentityUser` to the same `principalSet` (the repo). Schedule workflows (e.g. dbt daily run) check out at the default branch (`main`), so they pass the condition. |
| `main.tf` | Provider pin (`google ~> 5.40`), `terraform >= 1.6.0`, GCS backend (`bucket` & `prefix` passed at `init` time). |
| `locals.tf` | Every magic string lives here — bucket / SA / job / dataset names, lifecycle rule values, IAM role lists, common labels. |
| `variables.tf` / `outputs.tf` | Inputs / outputs (see tables below). |

## Identity flow (how a deploy authenticates)

```mermaid
sequenceDiagram
    autonumber
    participant Job as ⚙️ GitHub Actions
    participant STS as 🔒 Google STS
    participant IAM as 🎫 IAM Credentials
    participant GCP as ☁️ GCP APIs

    rect rgb(102, 126, 234, 0.12)
        Note over Job,STS: 🔐 OIDC Token Exchange
        Job->>STS: OIDC token<br/>(token.actions.githubusercontent.com)
        Note over STS: Verify attribute condition<br/>repository == var.github_repo<br/>ref == refs/heads/main
        STS-->>Job: Federated access token<br/>(principalSet)
    end

    rect rgb(79, 172, 254, 0.12)
        Note over Job,IAM: 🎫 Access Token Minting
        Job->>IAM: generateAccessToken<br/>for gharchive-ci-deployer SA
        IAM-->>Job: Short-lived access token
    end

    rect rgb(56, 239, 125, 0.12)
        Note over Job,GCP: ✅ Deploy Operations
        Job->>GCP: gcloud / terraform / docker push<br/>(as gharchive-ci-deployer)
        GCP-->>Job: 200 OK
    end
```

At runtime (independent of CI):

- **Cloud Scheduler** authenticates to the Cloud Run Job admin API using an OAuth token minted for `gharchive-invoker`.
- **Cloud Run Job** runs the container with `gharchive-runner` as its identity, which has just enough scope to write objects to the raw bucket.

No service-account key files are issued or stored anywhere.

## Input variables

- **Required (3)** — `project_id`, `region`, `github_repo`. No defaults; supply via `terraform.tfvars` (local) or `TF_VAR_*` env vars (CI sets these from GitHub secrets/variables + `${{ github.repository }}`).
- **Operational defaults (8)** — ingest lag/catchup, scheduler cron, Cloud Run sizing, retry counts. See `variables.tf` for the full list and validators; defaults are tuned for the portfolio workload and rarely need changing.

For local runs, copy `terraform.tfvars.example` → `terraform.tfvars` and fill in the three required values. `terraform.tfvars` is gitignored — CI gets the same values via `TF_VAR_*` from GitHub Actions secrets/variables.

## Outputs → GitHub secrets / variables (`outputs.tf`)

After `terraform apply`, copy these five outputs into the repo's Actions config (Settings → Secrets and variables → Actions). `project_id` and `region` go into **Variables** — they're public identifiers (Google's security model gates access via auth, not project IDs), and leaving them unmasked makes CI logs debuggable. The three SA/WIF identifiers go into **Secrets** to avoid leaking the exact impersonation surface.

| Terraform output | GitHub config | Type | Used by |
|---|---|---|---|
| `project_id` | `GCP_PROJECT_ID` | **Variable** | all workflows |
| `region` | `GCP_REGION` | **Variable** | all workflows |
| `ci_deployer_sa_email` | `GCP_SA_EMAIL` | Secret | `google-github-actions/auth` for `terraform.yml` & `ingest-deploy.yml` |
| `wif_provider_id` | `GCP_WIF_PROVIDER` | Secret | `google-github-actions/auth` (the provider resource path) |
| `dbt_runner_sa_email` | `DBT_RUNNER_SA_EMAIL` | Secret | `google-github-actions/auth` for `dbt-run.yml` (the dbt SA to impersonate) |

Other outputs (`gharchive_bucket_name`, `artifact_repo_id`, `cloud_run_job_name`, `runner_sa_email`, `bq_dataset`, `bq_dw_dataset`, `bq_dw_dev_dataset`) are informational — handy for `gcloud` one-liners and `bq` queries.

## Bootstrap → first apply (one-time)

The Terraform state bucket can't be managed by the Terraform that *lives in* it. `bootstrap.sh` handles that chicken-and-egg:

```bash
cd terraform
PROJECT_ID=my-gharchive-prod REGION=asia-northeast3 ./bootstrap.sh
```

The script creates the state bucket with versioning, UBLA, public-access-prevention, and a noncurrent-version lifecycle (keep recent versions ≤ 10, delete others older than 90 days). It's idempotent — safe to re-run.

> **Bucket name must match `local.tfstate_bucket_name`** (`${PROJECT_ID}-gharchive-tfstate`). `iam.tf` grants `gharchive-ci-deployer` `roles/storage.admin` on exactly that name — if the bucket lives anywhere else, CI applies fail at backend lock time.

Then:

```bash
terraform init \
  -backend-config="bucket=${PROJECT_ID}-gharchive-tfstate" \
  -backend-config="prefix=terraform/state"

cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars

terraform plan
terraform apply        # first apply runs locally with your owner-level creds
```

After the first apply:

1. Copy the five outputs above into GitHub repo Actions config (`project_id` and `region` → Variables, the other three → Secrets).
2. Push to `main` → `ingest-deploy.yml` builds the first real image and points the Job at it (replacing the bootstrap placeholder).
3. From here on, all infra changes go through `terraform.yml` (plan + apply on push to `main`). Run `terraform plan` locally before merging — the workflow does not post plans to PRs (PR branches cannot authenticate to WIF by design).

**Known first-apply gotchas:**

- **IAM propagation races.** Freshly-enabled APIs sometimes 403 on dependent resources — re-run `terraform apply`.
- **BQ external table needs a seed Parquet.** `autodetect = true` infers schema from existing files; first apply fails on an empty bucket. Run one local ingest hour (`cd ingest && python -m gharchive` with `GCS_RAW_BUCKET=<bucket>`, `TARGET_HOUR=<YYYY-MM-DD-H>`), then re-apply.
- **Implicit-dependency misses.** `google_bigquery_table` ↔ dataset and WIF pool ↔ provider use string IDs (not resource refs); first apply may 404 — re-run.

## CI/CD wiring

- **`.github/workflows/terraform.yml`** — runs on push to `main` for `terraform/**`. Authenticates via WIF, pins `terraform_version: 1.9.5` via `hashicorp/setup-terraform`, then runs `fmt -check -recursive` + `init` + `validate` + `plan` + `apply` of the saved `tfplan`. Required variables are supplied via `TF_VAR_*` env vars at the job level: `TF_VAR_project_id` and `TF_VAR_region` from GitHub secrets, `TF_VAR_github_repo` from the built-in `${{ github.repository }}` context (no separate secret). Operational-tuning variables fall back to defaults in `variables.tf`. PRs intentionally do not trigger this workflow — the WIF attribute condition only mints tokens for `refs/heads/main`, so run `terraform plan` locally before opening a PR. Concurrency group `terraform-${{ github.ref }}` with `cancel-in-progress: false` serialises applies against the GCS state lock.
- **`.github/workflows/ingest-deploy.yml`** — runs on push to `main` for `ingest/**`. Builds the image, pushes to Artifact Registry tagged with `${{ github.sha }}`, then `gcloud run jobs update gharchive --image=…` flips the Job to the new tag. Lifecycle ignore in `cloud_run_job.tf` is what makes this safe to do out-of-band from Terraform.
- **`.github/dependabot.yml`** tracks two ecosystems weekly (max 5 open PRs each): `github-actions` at the repo root, and `pip` under `/dbt` (for `dbt-core` / `dbt-bigquery`). The ingest `pyproject.toml` is not on Dependabot — pin updates land via manual PRs.

## Service accounts

| SA | Used by | Roles |
|---|---|---|
| `gharchive-ci-deployer` | GitHub Actions (`terraform.yml`, `ingest-deploy.yml`) via WIF | project: `viewer`, `run.developer`, `cloudscheduler.admin`, `artifactregistry.admin`, `iam.serviceAccountAdmin`, `resourcemanager.projectIamAdmin`, `bigquery.jobUser`, `bigquery.dataEditor`. bucket: `storage.admin` on tfstate + raw buckets. dataset: `bigquery.dataOwner` on `raw__gharchive`, `dw`, and `dw_dev`. impersonation: `iam.serviceAccountUser` on `gharchive-runner`. |
| `gharchive-runner` | Cloud Run Job runtime | bucket: `storage.objectCreator` + `storage.objectViewer` on raw bucket. |
| `gharchive-invoker` | Cloud Scheduler → Cloud Run Job admin API | project: `run.invoker`. |
| `gharchive-dbt-runner` | GitHub Actions (`dbt-run.yml`) via WIF | project: `bigquery.jobUser`, `bigquery.readSessionUser`. dataset: `bigquery.dataViewer` on `raw__gharchive`, `bigquery.dataEditor` on `dw` and `dw_dev`. |

**Why the non-obvious choices:**

- **`roles/viewer` on ci_deployer** — `terraform plan` refreshes every managed resource; refresh needs read on resources CI cannot modify (SAs, WIF pool/provider, etc.).
- **`iam.serviceAccountAdmin` + `resourcemanager.projectIamAdmin` on ci_deployer** — Terraform manages all four service accounts and their project / dataset / bucket IAM bindings. Without these, every IAM diff would require a local apply with owner creds, defeating the point of CI-driven Terraform.
- **Project-level `bigquery.dataEditor` on ci_deployer** — needed for refresh on dataset-level resources whose ACLs cross dataset boundaries; dataset-scoped `dataOwner` alone is not enough for some refresh paths.
- **`storage.admin` (not `storage.objectAdmin`) on tfstate + raw buckets** — refresh of `google_storage_bucket_iam_member` calls `getIamPolicy`, which isn't in viewer/objectAdmin.
- **`storage.objectViewer` on runner** — the ingest container calls `blob.exists()` for the `_SUCCESS` idempotency contract; `objectCreator` alone 403s.

ci_deployer is a high-privilege identity (project IAM admin). The blast-radius mitigation is **at the WIF layer**, not the role layer: the OIDC provider only mints tokens for this repo on `refs/heads/main` (see `wif.tf` attribute condition), so a malicious PR — which is necessarily on a non-`main` ref — cannot reach ci_deployer at all. Bootstrap edits that predate the WIF pool itself are still applied locally with owner creds.

## Operational notes

A few choices in here look conservative — they're deliberate:

- **`scheduler_retry_count = 0` + `cloud_run_job_max_retries = 1`.** The ingest container already retries every HTTP fetch up to 5× (`GharchiveClient._fetch_with_retry`) and re-attempts gap hours every run via `CATCHUP_HOURS`. Adding scheduler retries would risk a second invocation racing a still-running first one, and Cloud Run Job retries can't distinguish "really failed" from "gharchive hasn't published this hour yet". See [`ingest/README.md`](../ingest/README.md) for the retry semantics.
- **GCS lifecycle tiering (30d → Nearline, 90d → Coldline, 180d → delete).** Hot partitions stay on Standard for BigQuery query performance; older partitions get cheaper without breaking the external table (BigQuery reads all three classes transparently). 180-day retention is sized for portfolio/demo analytics — bump it via `gcs_delete_age_days` in `locals.tf` if you need a longer window.
- **Dataset-scoped `bigquery.dataOwner` on `raw__gharchive` / `dw` / `dw_dev`, project-wide `bigquery.jobUser` + `bigquery.dataEditor`.** ci_deployer fully owns the three project-managed datasets and can run jobs / edit data project-wide; it does not get `dataOwner` on datasets it didn't create. dbt_runner is narrower: read-only on `raw__gharchive`, writer on `dw` / `dw_dev`.
- **WIF attribute condition pinned to `main` only.** ci_deployer holds project IAM admin, so the blast radius is contained by *who can assume it*, not by *what it can do*. Only the OIDC subject `repository == var.github_repo && ref == "refs/heads/main"` can mint a token — PR branches fail the condition outright. Trade-off: PR `terraform plan` comments aren't possible without a separate read-only SA; run plan locally instead.
- **External table, not native.** GCS is the source of truth; BigQuery just queries it. Reprocessing an hour is "delete the Parquet + `_SUCCESS`, rerun the Job" — no `MERGE`s, no partition swaps.
