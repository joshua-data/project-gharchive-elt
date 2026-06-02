from __future__ import annotations

import logging
import sys
from collections.abc import Iterator
from datetime import UTC, datetime, timedelta
from typing import Any

from .config import Settings, load_settings
from .gharchive_client import GharchiveClient
from .models import Event
from .gcs_writer import GCSWriter, build_object_path, build_success_marker_path

log = logging.getLogger("gharchive")

def _configure_logging() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
        stream=sys.stdout,
    )

def to_hour(dt: datetime) -> str:
    """Render a datetime as YYYY-MM-DD-H."""
    date_str = dt.strftime("%Y-%m-%d")
    hour_str = str(dt.hour)
    return f"{date_str}-{hour_str}"


def to_dt(hour: str) -> datetime:
    """Parse YYYY-MM-DD-H back to a datetime."""
    date_str, hour_str = hour.rsplit("-", 1)
    return datetime.strptime(date_str, "%Y-%m-%d").replace(
        hour=int(hour_str),
        tzinfo=UTC,
    )


def iter_hours(start_hour: str, end_hour: str) -> Iterator[str]:
    """Yield YYYY-MM-DD-H keys from start_hour..end_hour inclusive (chronological)."""
    curr_dt, end_dt = to_dt(start_hour), to_dt(end_hour)
    if curr_dt > end_dt:
        raise ValueError(f"start_hour {start_hour} is after end_hour {end_hour}")
    while curr_dt <= end_dt:
        yield to_hour(curr_dt)
        curr_dt += timedelta(hours=1)


def resolve_target_hours(settings: Settings, now_dt: datetime) -> list[str]:
    """Pick the target hours list based on the settings.
        - Priority 1: target_start_hour & target_end_hour (explicit range backfill)
        - Priority 2: target_hour (explicit single hour backfill)
        - Priority 3: auto mode — [now - lag - catchup .. now - lag] inclusive.
                      catchup_hours = 0 reproduces the original single-hour behavior.
                      _SUCCESS markers make repeated hours skip cheaply, so this
                      window naturally heals one-off gaps without a separate job.
    """
    if bool(settings.target_start_hour) != bool(settings.target_end_hour):
        raise ValueError("TARGET_START_HOUR and TARGET_END_HOUR must be set together")
    if settings.target_start_hour and settings.target_end_hour:
        hours = list(iter_hours(settings.target_start_hour, settings.target_end_hour))
        return hours
    if settings.target_hour:
        hours = [settings.target_hour]
        return hours
    end_dt = now_dt - timedelta(hours=settings.lag_hours)
    start_dt = end_dt - timedelta(hours=settings.catchup_hours)
    hours = list(iter_hours(to_hour(start_dt), to_hour(end_dt)))
    return hours


def process_hour(
        hour: str,
        *,
        gharchive_client: GharchiveClient,
        gcs_writer: GCSWriter,
        ingested_at: str,
) -> dict[str, Any]:
    
    hour_dt = to_dt(hour)
    object_path = build_object_path("events", hour_dt)
    success_marker_path = build_success_marker_path("events", hour_dt)
    if gcs_writer.is_existing(success_marker_path):
        log.info("skip already-complete hour=%s marker=%s", hour, success_marker_path)
        return {"status": "skipped", "count": 0}
    
    count = 0

    def iter_events() -> Iterator[dict[str, Any]]:
        nonlocal count
        for raw_event in gharchive_client.download_hour(hour):
            count += 1
            yield Event.from_raw(raw_event, hour=hour, ingested_at=ingested_at).to_dict()
    
    written_bytes = gcs_writer.write_parquet(object_path, iter_events())
    if written_bytes == 0:
        log.warning("empty payload, skipping marker hour=%s (will retry next run)", hour)
        return {"status": "empty", "count": count}
    else:
        gcs_writer.touch_empty_file(success_marker_path)
        log.info("hour complete hour=%s count=%d path=%s", hour, count, object_path)
        return {"status": "ok", "count": count}


def run() -> int:
    
    settings = load_settings()
    now_dt = datetime.now(UTC)
    hours = resolve_target_hours(settings, now_dt)
    log.info("ingest start hours=%d range=[%s..%s]", len(hours), hours[0], hours[-1])

    gharchive_client = GharchiveClient(base_url=settings.gharchive_base_url, timeout=settings.http_timeout)
    gcs_writer = GCSWriter(settings.gcs_raw_bucket)
    ingested_at = now_dt.isoformat()

    ok = skipped = empty = failed = 0
    total_count = 0
    for hour in hours:
        try:
            result = process_hour(hour, gharchive_client=gharchive_client, gcs_writer=gcs_writer, ingested_at=ingested_at)
        except Exception:
            log.exception("hour failed hour=%s", hour)
            failed += 1
            continue
        total_count += result["count"]
        status = result["status"]
        if status == "ok":
            ok += 1
        elif status == "skipped":
            skipped += 1
        elif status == "empty":
            empty += 1

    log.info("ingest done ok=%d skipped=%d empty=%d failed=%d total_count=%d", ok, skipped, empty, failed, total_count)
    return 1 if (failed or empty) else 0


def main() -> int:
    _configure_logging()
    try:
        return run()
    except Exception:
        log.exception("ingestion failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())
