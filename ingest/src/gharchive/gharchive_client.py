from __future__ import annotations

import gzip
import json
import logging
import tempfile
import time
from collections.abc import Iterator
from typing import IO, Any

import httpx

log = logging.getLogger(__name__)

DOWNLOAD_CHUNK_BYTES = 1 << 20


class GharchiveClient:
    """Streaming downloader for https://data.gharchive.org/YYYY-MM-DD-HH.json.gz."""

    def __init__(
            self,
            base_url: str,
            timeout: float,
            max_retries: int = 5,
            retry_backoff: float = 5.0,
    ) -> None:

        self._base_url = base_url.rstrip("/")
        self._timeout = timeout
        self._max_retries = max_retries
        self._retry_backoff = retry_backoff


    def url_for(self, hour: str) -> str:
        url = f"{self._base_url}/{hour}.json.gz"
        return url

    # Spool the compressed payload to a temp file, then decompress and yield JSON objects
    # line-by-line. Peak memory stays flat no matter how large the hourly archive is.
    def download_hour(self, hour: str) -> Iterator[dict[str, Any]]:
        url = self.url_for(hour)
        with tempfile.NamedTemporaryFile(suffix=".json.gz") as spool:
            size = self._fetch_with_retry(url, spool)
            log.info("fetched %s (%d bytes gz)", url, size)
            spool.seek(0)

            with gzip.open(spool, "rb") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        yield json.loads(line)
                    except json.JSONDecodeError as err:
                        log.warning("skip malformed line: %s", err)

    def _fetch_with_retry(self, url: str, sink: IO[bytes]) -> int:
        last_exc: Exception | None = None

        for attempt in range(1, self._max_retries + 1):
            sink.seek(0)
            sink.truncate()
            try:
                return self.stream_http(url, self._timeout, sink)
            except httpx.HTTPStatusError as exc:
                last_exc = exc
                status = exc.response.status_code
                if status == 404:
                    # gharchive file not yet published
                    delay = min(self._retry_backoff * attempt, 60.0)
                    log.warning("%d for %s (attempt %d/%d); sleeping %.1fs", status, url, attempt, self._max_retries, delay)
                    time.sleep(delay)
                    continue
                if 500 <= status < 600:
                    # server error, may be transient
                    delay = self._retry_backoff * attempt
                    log.warning("%d for %s (attempt %d/%d); sleeping %.1fs", status, url, attempt, self._max_retries, delay)
                    time.sleep(delay)
                    continue
                raise
            except (httpx.RequestError, httpx.TimeoutException) as exc:
                # Network error or timeout, may be transient
                last_exc = exc
                delay = self._retry_backoff * attempt
                log.warning("network error for %s (attempt %d/%d): %s; sleeping %.1fs", url, attempt, self._max_retries, exc, delay)
                time.sleep(delay)
                continue
        raise RuntimeError(f"failed to fetch {url} after {self._max_retries} attempts") from last_exc

    @staticmethod
    def stream_http(url: str, timeout: float, sink: IO[bytes]) -> int:
        """Stream the response body into `sink` in fixed-size chunks; return bytes written."""
        written = 0
        with (
            httpx.Client(timeout=timeout, follow_redirects=True) as client,
            client.stream("GET", url) as response,
        ):
            response.raise_for_status()
            for chunk in response.iter_bytes(chunk_size=DOWNLOAD_CHUNK_BYTES):
                sink.write(chunk)
                written += len(chunk)
        sink.flush()
        return written
