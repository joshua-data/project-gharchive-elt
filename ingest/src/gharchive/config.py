from __future__ import annotations

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    gcs_raw_bucket: str

    gharchive_base_url: str = "https://data.gharchive.org"
    http_timeout: float = 120.0

    target_hour: str = Field(
        default="",
        description="Explicit YYYY-MM-DD-H for single-hour backfill. Empty = now - lag_hours.",
    )
    target_start_hour: str = Field(
        default="",
        description="Inclusive range start YYYY-MM-DD-H for multi-hour backfill. Requires target_end_hour.",
    )
    target_end_hour: str = Field(
        default="",
        description="Inclusive range end YYYY-MM-DD-H for multi-hour backfill. Requires target_start_hour.",
    )

    lag_hours: int = Field(
        default=1,
        description="When no explicit hour is set.",
    )
    catchup_hours: int = Field(
        default=3,
        description="In auto mode, also re-process this many hours older than now-lag_hours. Idempotent (skips hours with _SUCCESS marker), so cost is near-zero. Provides automatic gap recovery.",
    )

def load_settings() -> Settings:
    return Settings()
