#!/usr/bin/env bash
# ==================================================================================
# Bootstrap the Terraform state bucket for project-gharchive-elt
# ----------------------------------------------------------------------------------
# The GCS bucket that *stores its own state* must exist before `terraform init`.
# This script creates it. (idempotent)
# ----------------------------------------------------------------------------------
# Usage:
#   PROJECT_ID=your-gcp-project-id REGION=asia-northeast3 ./bootstrap.sh
# Requires:
#   gcloud auth login + project owner (or storage.admin) on PROJECT_ID.
# ==================================================================================

set -euo pipefail

: "${PROJECT_ID:?PROJECT_ID env var is required}"
: "${REGION:?REGION env var is required (e.g. asia-northeast3)}"

BUCKET="${PROJECT_ID}-gharchive-tfstate"
URL="gs://${BUCKET}"

echo "==> bootstrapping state bucket ${URL} in ${REGION} (project=${PROJECT_ID})"

if gcloud storage buckets describe "${URL}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  echo "    bucket already exists — re-applying protections"
else
  gcloud storage buckets create "${URL}" \
    --project="${PROJECT_ID}" \
    --location="${REGION}" \
    --default-storage-class=STANDARD \
    --uniform-bucket-level-access \
    --public-access-prevention
fi

gcloud storage buckets update "${URL}" \
  --project="${PROJECT_ID}" \
  --versioning \
  --uniform-bucket-level-access \
  --public-access-prevention

cat <<EOF >/tmp/tfstate-lifecycle.json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "numNewerVersions": 10,
          "isLive": false
        }
      },
      {
        "action": {"type": "Delete"},
        "condition": {
          "daysSinceNoncurrentTime": 90,
          "isLive": false
        }
      }
    ]
  }
}
EOF

gcloud storage buckets update "${URL}" \
  --project="${PROJECT_ID}" \
  --lifecycle-file=/tmp/tfstate-lifecycle.json

rm -f /tmp/tfstate-lifecycle.json

echo "==> done. next: terraform init -backend-config=\"bucket=${BUCKET}\" -backend-config=\"prefix=terraform/state\""
