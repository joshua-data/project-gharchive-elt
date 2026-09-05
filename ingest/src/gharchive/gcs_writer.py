from __future__ import annotations

import json
import logging
import os
import tempfile
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

# Row-group flush thresholds. Whichever trips first bounds how much sits in memory at once.
PARQUET_BATCH_MAX_BYTES = 16 * 1024 * 1024
PARQUET_BATCH_MAX_ROWS = 20_000


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


def _encoded_row_bytes(row: dict[str, Any]) -> int:
    return sum(len(row[json_field]) for json_field in _JSON_FIELDS if row[json_field] is not None)


def _write_parquet_file(path: str, events: Iterable[dict[str, Any]]) -> int:
    """Stream events into a Parquet file one row group at a time; return the row count.

    Nothing is created when the source yields no events, which keeps the caller's
    "no rows written -> no _SUCCESS marker" contract intact.
    """
    writer: pq.ParquetWriter | None = None
    batch: list[dict[str, Any]] = []
    batch_bytes = 0
    rows = 0

    def flush() -> None:
        nonlocal writer, batch_bytes, rows
        if not batch:
            return
        if writer is None:
            writer = pq.ParquetWriter(path, PARQUET_SCHEMA, compression="snappy")
        writer.write_batch(pa.RecordBatch.from_pylist(batch, schema=PARQUET_SCHEMA))
        rows += len(batch)
        batch.clear()
        batch_bytes = 0

    try:
        for event in events:
            row = _encode_nested_fields_as_json(event)
            batch.append(row)
            batch_bytes += _encoded_row_bytes(row)
            if len(batch) >= PARQUET_BATCH_MAX_ROWS or batch_bytes >= PARQUET_BATCH_MAX_BYTES:
                flush()
        flush()
    finally:
        if writer is not None:
            writer.close()

    return rows


class GCSWriter:

    def __init__(self, bucket_name: str, client: storage.Client | None = None) -> None:
        self._client = client or storage.Client()
        self._bucket = self._client.bucket(bucket_name)

    def write_parquet(self, object_path: str, events: Iterable[dict[str, Any]]) -> int:
        with tempfile.TemporaryDirectory() as tmpdir:
            local_path = os.path.join(tmpdir, os.path.basename(object_path))
            rows = _write_parquet_file(local_path, events)
            if rows == 0:
                log.info("skip empty payload: %s", object_path)
                return 0

            size = os.path.getsize(local_path)
            blob = self._bucket.blob(object_path)
            blob.upload_from_filename(local_path, content_type="application/octet-stream")

        log.info("wrote gs://%s/%s (%d rows, %d bytes)", self._bucket.name, object_path, rows, size)
        return size

    def is_existing(self, object_path: str) -> bool:
        return self._bucket.blob(object_path).exists(self._client)

    def touch_empty_file(self, object_path: str) -> None:
        blob = self._bucket.blob(object_path)
        blob.upload_from_string(b"", content_type="application/octet-stream")
        log.info("wrote empty file gs://%s/%s", self._bucket.name, object_path)
