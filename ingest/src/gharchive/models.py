from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any


@dataclass(slots=True)
class Event:

    # GitHub Events API common properties
    id: int
    type: str
    actor: dict[str, Any]
    repo: dict[str, Any]
    payload: dict[str, Any]
    public: bool
    created_at: str
    org: dict[str, Any] | None # The property appears in the event object only if it is applicable.

    # Lineage properties
    hour: str
    ingested_at: str

    @classmethod
    def from_raw(cls, raw_event: dict[str, Any], hour: str, ingested_at: str) -> Event:
        return cls(
            id=int(raw_event["id"]),
            type=raw_event["type"],
            actor=raw_event["actor"],
            repo=raw_event["repo"],
            payload=raw_event["payload"],
            public=bool(raw_event["public"]),
            created_at=raw_event["created_at"],
            org=raw_event.get("org"),
            hour=hour,
            ingested_at=ingested_at,
        )

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
