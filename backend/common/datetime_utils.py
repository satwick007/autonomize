from __future__ import annotations

from datetime import datetime
from zoneinfo import ZoneInfo


IST = ZoneInfo("Asia/Kolkata")


def now_ist() -> datetime:
    return datetime.now(IST)


def now_ist_naive() -> datetime:
    return now_ist().replace(tzinfo=None)


def today_ist():
    return now_ist().date()
