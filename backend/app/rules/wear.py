from __future__ import annotations

from datetime import date
from typing import Any


def days_unworn(item: dict[str, Any], wear_events: list[dict[str, Any]], today: date) -> int:
    dates: list[date] = []
    for event in wear_events:
        if event.get("worn_date"):
            dates.append(date.fromisoformat(event["worn_date"]))
    estimate = item.get("last_worn_estimate")
    if estimate:
        dates.append(date.fromisoformat(estimate[:10]))
    base = max(dates) if dates else date.fromisoformat(item["created_at"][:10])
    return max(0, (today - base).days)


def is_dormant(days: int) -> bool:
    return days >= 30


def gap_days(item_id: str, worn_date: date, prior_events: list[dict[str, Any]], item: dict[str, Any]) -> int:
    dates = [date.fromisoformat(e["worn_date"]) for e in prior_events if item_id in str(e.get("items", ""))]
    return (worn_date - max(dates)).days if dates else 0


def rescue_eligible(gap: int) -> bool:
    return gap >= 30
