"""Tests for environment-backed application configuration."""

import pytest

from backend.app.config import allowed_frontend_origins


def test_allowed_origins_are_trimmed_and_split(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv(
        "CALY_ALLOWED_ORIGINS",
        " https://caly.example/, https://preview.example ",
    )

    assert allowed_frontend_origins() == [
        "https://caly.example",
        "https://preview.example",
    ]


def test_allowed_origins_default_to_empty(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("CALY_ALLOWED_ORIGINS", raising=False)

    assert allowed_frontend_origins() == []
