# terraform

All GCP infrastructure for this project. One Terraform root module — no submodules, no workspaces — that provisions storage, BigQuery, the Cloud Run Job and its scheduler, all the service accounts and IAM, and the Workload Identity Federation pool that GitHub Actions uses for keyless authentication.

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
        CID["💼 ci-deployer<br/><i>broad project admin</i>"]
        RUN["🤖 gharchive-runner<br/><i>storage.objectCreator</i>"]
        INV["🤖 gharchive-invoker<br/><i>run.invoker</i>"]
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
    end

    GHA --> POOL --> PROV
    PROV -->|"impersonates"| CID
    CID -->|"manages"| AR
    CID -->|"manages"| SCH
    CID -->|"manages"| JOB
    CID -->|"manages"| GCS
    CID -->|"manages"| BQDS
    CID -.->|"impersonates (deploy)"| RUN

    SCH -->|"POST :run as"| INV
    INV --> JOB
    JOB -->|"runs as"| RUN
    JOB -->|"writes Parquet"| GCS
    GCS --> BQT
    BQT --> BQDS

    classDef primary   fill:#667eea,stroke:#764ba2,color:#fff,stroke-width:3px
    classDef secondary fill:#4facfe,stroke:#00f2fe,color:#fff,stroke-width:2px
    classDef accent    fill:#f093fb,stroke:#f5576c,color:#fff,stroke-width:2px
    classDef alert     fill:#f5576c,stroke:#c0392b,color:#fff,stroke-width:3px
    classDef success   fill:#38ef7d,stroke:#11998e,color:#1e293b,stroke-width:3px
    classDef warning   fill:#fef3c7,stroke:#f59e0b,color:#78350f,stroke-width:2px
    classDef neutral   fill:#f8fafc,stroke:#cbd5e1,color:#1e293b,stroke-width:1px

    class JOB,SCH primary
    class GCS,RUN,INV secondary
    class CID alert
    class POOL,PROV warning
    class AR warning
    class BQT,BQDS success
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
| `gcs.tf` | Raw bucket `{project}-gharchive` — UBLA, public-access-prevention enforced, 7-day soft-delete window, and a lifecycle that promotes objects Standard → Nearline (30d) → Coldline (90d) → delete (730d). |
| `bigquery.tf` | Dataset `raw__gharchive` and external table `ext__events` over `gs://{bucket}/events/dt=*/hr=*/*.parquet` with `hive_partitioning_options.mode = "AUTO"` and `autodetect = true`. `deletion_protection = true`. |
| `artifact_registry.tf` | Docker repo `gharchive` with two cleanup policies — keep the 10 most-recent versions, delete untagged images older than 24 h. |
| `cloud_run_job.tf` | Job `gharchive` running as the `gharchive-runner` SA, env vars `GCS_RAW_BUCKET` / `LAG_HOURS` / `CATCHUP_HOURS`, CPU/memory/timeout from variables, `max_retries = 1`. Uses Google's placeholder `cloudrun/container/job` image at bootstrap; `lifecycle.ignore_changes = [containers[0].image]` so the CI image tag updates don't get reverted on `terraform apply`. |
| `cloud_scheduler.tf` | Cron job that POSTs to the Job's `:run` admin endpoint as the `gharchive-invoker` SA. Retry policy: `retry_count = 0`, min/max backoff 30s/300s — intentional (see *Operational notes*). |
| `iam.tf` | The three service accounts above. Project-scoped roles for `ci-deployer`; dataset-scoped `bigquery.dataOwner` plus project-scoped `bigquery.jobUser`; `gharchive-runner` gets bucket-scoped `storage.objectCreator`; `ci-deployer` is granted `iam.serviceAccountUser` on `gharchive-runner` so CI can deploy on its behalf. |
| `wif.tf` | Pool `github-pool` + OIDC provider `github-provider`. Attribute mapping (`google.subject`, `attribute.repository`, `attribute.ref`, `attribute.actor`) and an **attribute condition** that hard-locks the provider to this repo on `main` or `refs/pull/*` only — nothing else in the org can mint a token that impersonates `ci-deployer`. |
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
        Note over STS: Verify attribute condition<br/>repository == var.github_repo<br/>ref == main OR refs/pull/*
        STS-->>Job: Federated access token<br/>(principalSet)
    end

    rect rgb(79, 172, 254, 0.12)
        Note over Job,IAM: 🎫 Access Token Minting
        Job->>IAM: generateAccessToken<br/>for ci-deployer SA
        IAM-->>Job: Short-lived access token
    end

    rect rgb(56, 239, 125, 0.12)
        Note over Job,GCP: ✅ Deploy Operations
        Job->>GCP: gcloud / terraform / docker push<br/>(as ci-deployer)
        GCP-->>Job: 200 OK
    end
```

At runtime (independent of CI):

- **Cloud Scheduler** authenticates to the Cloud Run Job admin API using an OAuth token minted for `gharchive-invoker`.
- **Cloud Run Job** runs the container with `gharchive-runner` as its identity, which has just enough scope to write objects to the raw bucket.

No service-account key files are issued or stored anywhere.

## Input variables (`variables.tf`)

| Name | Type | Default / Example | Notes |
|---|---|---|---|
| `project_id` | string | — | Target GCP project. |
| `region` | string | `asia-northeast3` | Region for all regional resources; GCS bucket co-located. |
| `github_repo` | string | `owner/repo` | Pinned in the WIF attribute condition. |
| `lag_hours` | number | `1` | Passed to the Job as `LAG_HOURS`. Validator: `>= 0`. |
| `catchup_hours` | number | `3` | Passed to the Job as `CATCHUP_HOURS`. Validator: `>= 0`. |
| `schedule_cron` | string | `30 * * * *` | 5-field cron (validated by regex). Job timezone is `Etc/UTC`. |
| `scheduler_retry_count` | number | `0` | See *Operational notes*. Validator: `>= 0`. |
| `cloud_run_job_max_retries` | number | `1` | See *Operational notes*. Validator: `>= 0`. |
| `cloud_run_job_timeout` | string | `900s` | Per-task wall-clock cap. |
| `cloud_run_job_cpu` | string | `1` | vCPU per task. |
| `cloud_run_job_memory` | string | `1Gi` | Memory per task. |

Copy `terraform.tfvars.example` → `terraform.tfvars` to fill in.

## Outputs → GitHub secrets (`outputs.tf`)

After `terraform apply`, copy these into the repo's Actions secrets — they're the only thing the workflows need.

| Terraform output | GitHub secret | Used by |
|---|---|---|
| `project_id` | `GCP_PROJECT_ID` | both workflows |
| `region` | `GCP_REGION` | both workflows |
| `ci_deployer_sa_email` | `GCP_SA_EMAIL` | `google-github-actions/auth` (the SA to impersonate) |
| `wif_provider` | `GCP_WIF_PROVIDER` | `google-github-actions/auth` (the provider resource path) |

Other outputs (`raw_bucket`, `artifact_registry_repo`, `cloud_run_job_name`, `runner_sa_email`, `bq_dataset`) are informational — handy for `gcloud` one-liners and `bq` queries.

## Bootstrap → first apply (one-time)

The Terraform state bucket can't be managed by the Terraform that *lives in* it. `bootstrap.sh` handles that chicken-and-egg:

```bash
cd terraform
PROJECT_ID=my-gharchive-prod REGION=asia-northeast3 ./bootstrap.sh
```

The script creates `gs://${PROJECT_ID}-tfstate` with versioning, UBLA, public-access-prevention, and a noncurrent-version lifecycle (keep recent versions ≤ 10, delete others older than 90 days). It's idempotent — safe to re-run.

Then:

```bash
terraform init \
  -backend-config="bucket=${PROJECT_ID}-tfstate" \
  -backend-config="prefix=terraform/state"

cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars

terraform plan
terraform apply        # first apply runs locally with your owner-level creds
```

After the first apply:

1. Copy the four outputs above into GitHub repo secrets.
2. Push to `main` → `ingest-deploy.yml` builds the first real image and points the Job at it (replacing the bootstrap placeholder).
3. From here on, all infra changes go through `terraform.yml` (plan on PR, apply on `main`).

## CI/CD wiring

- **`.github/workflows/terraform.yml`** — runs on PR and push to `main` for `terraform/**`. Authenticates via WIF, runs `fmt -check` + `validate` + `plan`. On PRs the plan is posted as a sticky comment. On `main` it `apply`s the saved plan. Concurrency group `terraform-{ref}` with `cancel-in-progress: false` serialises applies against the GCS state lock.
- **`.github/workflows/ingest-deploy.yml`** — runs on push to `main` for `ingest/**`. Builds the image, pushes to Artifact Registry tagged with `${{ github.sha }}`, then `gcloud run jobs update gharchive --image=…` flips the Job to the new tag. Lifecycle ignore in `cloud_run_job.tf` is what makes this safe to do out-of-band from Terraform.
- **`.github/dependabot.yml`** keeps the Action versions current (weekly, max 5 open PRs).

## Operational notes

A few choices in here look conservative — they're deliberate:

- **`scheduler_retry_count = 0` + `cloud_run_job_max_retries = 1`.** The ingest container already retries every HTTP fetch up to 5× (`GharchiveClient._fetch_with_retry`) and re-attempts gap hours every run via `CATCHUP_HOURS`. Adding scheduler retries would risk a second invocation racing a still-running first one, and Cloud Run Job retries can't distinguish "really failed" from "gharchive hasn't published this hour yet". See [`ingest/README.md`](../ingest/README.md) for the retry semantics.
- **GCS lifecycle tiering (30d → Nearline, 90d → Coldline, 730d → delete).** Hot partitions stay on Standard for BigQuery query performance; older partitions get cheaper without breaking the external table (BigQuery reads all three classes transparently).
- **Dataset-scoped `bigquery.dataOwner`, project-wide `bigquery.jobUser`.** `ci-deployer` can do anything inside `raw__gharchive` but can't read or write any other dataset in the project.
- **WIF attribute condition pinned to `main` + PRs.** Prevents anyone with push access to an arbitrary branch from minting tokens that impersonate `ci-deployer`.
- **External table, not native.** GCS is the source of truth; BigQuery just queries it. Reprocessing an hour is "delete the Parquet + `_SUCCESS`, rerun the Job" — no `MERGE`s, no partition swaps.
