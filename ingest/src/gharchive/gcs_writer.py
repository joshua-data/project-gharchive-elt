from __future__ import annotations

import io
import json
import logging
from collections.abc import Iterable
from datetime import datetime
from typing import Any

import pyarrow as pa
import pyarrow.parquet as pq
from google.cloud import storage

log = logging.getLogger(__name__)


# Drift-resilient schema design
# - stable top-level fields are typed.
# - polymorphic fields are JSON-encoded strings so GitHub schema changes never break the Parquet/BigQuery contract.

PARQUET_SCHEMA = pa.schema(
    [
        pa.field("id", pa.int64(), nullable=False),
        pa.field("type", pa.string(), nullable=False),
        pa.field("actor", pa.string(), nullable=False),
        pa.field("repo", pa.string(), nullable=False),
        pa.field("payload", pa.string(), nullable=False),
        pa.field("public", pa.bool_(), nullable=False),
        pa.field("created_at", pa.string(), nullable=False),
        pa.field("org", pa.string(), nullable=True),
        pa.field("hour", pa.string(), nullable=False),
        pa.field("ingested_at", pa.string(), nullable=False),
    ]
)

_JSON_FIELDS = ("actor", "repo", "payload", "org")


def build_object_path(dataset: str, hour_dt: datetime) -> str:
    """Hive-partitioned GCS object path keyed on the gharchive event hour
        - Example: events/dt=2026-05-29/hr=12/2026-05-29-12.parquet
    """
    date_str = hour_dt.strftime("%Y-%m-%d")
    hour_str = hour_dt.strftime("%H")
    path = f"{dataset}/dt={date_str}/hr={hour_str}/{date_str}-{hour_str}.parquet"
    return path


def build_success_marker_path(dataset: str, hour_dt: datetime) -> str:
    """Per-hour completion marker, sibling of the Parquet object"""
    date_str = hour_dt.strftime("%Y-%m-%d")
    hour_str = hour_dt.strftime("%H")
    path = f"{dataset}/dt={date_str}/hr={hour_str}/_SUCCESS"
    return path


def _encode_nested_fields_as_json(event: dict[str, Any]) -> dict[str, Any]:
    row = dict(event)
    for json_field in _JSON_FIELDS:
        value = row.get(json_field)
        row[json_field] = json.dumps(value, ensure_ascii=False) if value is not None else None
    return row


def _serialize_parquet(events: Iterable[dict[str, Any]]) -> bytes:
    rows = [_encode_nested_fields_as_json(event) for event in events]
    if not rows:
        return b""
    table = pa.Table.from_pylist(rows, schema=PARQUET_SCHEMA)
    buf = io.BytesIO()
    pq.write_table(table, buf, compression="snappy")
    return buf.getvalue()


class GCSWriter:

    def __init__(self, bucket_name: str, client: storage.Client | None = None) -> None:
        self._client = client or storage.Client()
        self._bucket = self._client.bucket(bucket_name)

    def write_parquet(self, object_path: str, events: Iterable[dict[str, Any]]) -> int:
        payload = _serialize_parquet(events)
        if not payload:
            log.info("skip empty payload: %s", object_path)
            return 0
        blob = self._bucket.blob(object_path)
        blob.upload_from_string(payload, content_type="application/octet-stream")
        size = len(payload)
        log.info("wrote gs://%s/%s (%d bytes)", self._bucket.name, object_path, size)
        return size

    def is_existing(self, object_path: str) -> bool:
        return self._bucket.blob(object_path).exists(self._client)

    def touch_empty_file(self, object_path: str) -> None:
        blob = self._bucket.blob(object_path)
        blob.upload_from_string(b"", content_type="application/octet-stream")
        log.info("wrote empty file gs://%s/%s", self._bucket.name, object_path)
