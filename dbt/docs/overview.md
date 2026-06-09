{% docs __overview__ %}

# gharchive ELT — dbt project overview

This dbt project turns the public **[GitHub Archive](https://www.gharchive.org/)**
event stream into curated facts and dimensions on BigQuery. Hourly `.json.gz`
files are landed as Hive-partitioned Parquet in GCS by an upstream ingest job
(outside dbt) and exposed via a BigQuery external table. dbt reads from that
external table and writes into the curated `dw` dataset.

---

## What dbt owns here

Two layers:

- **Staging** — a single fact model that reads the external table, flattens the
  per-event JSON envelope (actor / repo / org) into typed scalar columns, keeps
  the polymorphic `payload` as native `JSON`, and dedupes by event id across
  re-ingests.
- **Core** — built on staging:
  - **Transactional facts** — one per GitHub event type, each projecting the
    typed payload fields it cares about.
  - **SCD-1 dimensions** — conformed user / repo / org dimensions, latest
    attributes only (no history).
  - **Periodic-snapshot facts** — Activated Users (AU) rollups at
    daily / weekly / monthly grains per entity.

Incremental everywhere, partitioned by the relevant date column, clustered for
the common filter shape.

## How the daily batch is scoped

Every model calls the `batch_filter` macro, which requires one of two variables
and fails the compile otherwise (so `require_partition_filter` tables never get
a full scan by accident):

- `batch_date` → window is **`[batch_date − 1 day, batch_date]`**. The 1-day
  lookback mirrors the ingest job's catchup window so a late hour doesn't get
  stranded. Production runs nightly with `batch_date = yesterday UTC`.
- `batch_start_date` + `batch_end_date` → an explicit closed range, used for
  backfills.

Periodic-snapshot models pass an `interval` (`'week(sunday)'`, `'month'`, …) to
snap the lower bound back to the enclosing period start — each batch rewrites
the active period as a period-to-date (WTD / MTD) snapshot, and late-arriving
events propagate cleanly on the next run.

## Where to start

Use the **Models tree on the left** — staging is the entry point, then follow
the lineage into core for whichever event type, dimension, or snapshot grain
you care about. Each model's page documents its grain, partition / cluster
keys, and column semantics.

> **Note on data quality.** The data contract (test severities, freshness
> thresholds, schema-drift triage) is still being finalized. Until then, treat
> any tests you see on individual models as work-in-progress rather than
> promises.

{% enddocs %}
