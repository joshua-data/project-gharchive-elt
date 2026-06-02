#!/usr/bin/env bash
# ======================================================================================
# Run a local backfill against the prod GCS bucket without touching the Cloud Run Job.
# --------------------------------------------------------------------------------------
# Usage:
#   GCS_RAW_BUCKET=<bucket> TARGET_HOUR=2025-05-29-12 ./scripts/backfill.sh
#   GCS_RAW_BUCKET=<bucket> TARGET_START_HOUR=2025-05-29-00 TARGET_END_HOUR=2025-05-29-23 ./scripts/backfill.sh
# Prereqs:
#   `gcloud auth application-default login` once.
# ======================================================================================

set -euo pipefail

: "${GCS_RAW_BUCKET:?set GCS_RAW_BUCKET}"

if [[ -z "${TARGET_HOUR:-}" && -z "${TARGET_START_HOUR:-}" && -z "${TARGET_END_HOUR:-}" ]]; then
  echo "error: set TARGET_HOUR, or TARGET_START_HOUR+TARGET_END_HOUR" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ingest_dir="$(cd "$script_dir/.." && pwd)"

adc_path="${HOME}/.config/gcloud/application_default_credentials.json"
if [[ ! -f "$adc_path" ]]; then
  echo "error: $adc_path not found. Run: gcloud auth application-default login" >&2
  exit 2
fi

docker build -t gharchive-ingest:local "$ingest_dir"

docker run --rm \
  -e GCS_RAW_BUCKET \
  -e TARGET_HOUR \
  -e TARGET_START_HOUR \
  -e TARGET_END_HOUR \
  -e GOOGLE_APPLICATION_CREDENTIALS=/secrets/adc.json \
  -v "${adc_path}:/secrets/adc.json:ro" \
  gharchive-ingest:local
