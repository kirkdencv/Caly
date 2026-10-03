"""Environment-backed configuration shared by the FastAPI application."""

import os
from pathlib import Path

from dotenv import load_dotenv

BACKEND_ENV_FILE = Path(__file__).resolve().parents[1] / ".env"


def load_backend_environment() -> None:
    """Load local development values without overriding host configuration."""

    load_dotenv(BACKEND_ENV_FILE)


def allowed_frontend_origins() -> list[str]:
    """Return normalized production origins from a comma-separated variable."""

    load_backend_environment()
    raw_origins = os.getenv("CALY_ALLOWED_ORIGINS", "")
    return [
        origin.strip().rstrip("/")
        for origin in raw_origins.split(",")
        if origin.strip()
    ]
