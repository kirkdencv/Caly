"""Unit tests for Gemini food interpretation and output validation."""

import asyncio
import json
from types import SimpleNamespace
from typing import Any

import pytest
from pydantic import ValidationError

from backend.app.schemas import GeminiFoodResult
from backend.app.services.gemini_food_service import (
    GeminiApiError,
    GeminiConfigurationError,
    GeminiFoodService,
    GeminiInvalidResponseError,
    GeminiTimeoutError,
)


def test_gemini_schema_avoids_unsupported_exclusive_bounds() -> None:
    encoded_schema = json.dumps(GeminiFoodResult.model_json_schema())

    assert "exclusiveMinimum" not in encoded_schema
    assert "exclusiveMaximum" not in encoded_schema
    assert "additionalProperties" not in encoded_schema


class FakeModels:
    def __init__(
        self,
        *,
        parsed: Any = None,
        text: str | None = None,
        error: Exception | None = None,
        delay: float = 0,
    ) -> None:
        self.parsed = parsed
        self.text = text
        self.error = error
        self.delay = delay
        self.call: dict[str, Any] | None = None

    async def generate_content(self, **kwargs: Any) -> Any:
        self.call = kwargs
        if self.delay:
            await asyncio.sleep(self.delay)
        if self.error:
            raise self.error
        return SimpleNamespace(parsed=self.parsed, text=self.text)


class FakeClient:
    def __init__(self, models: FakeModels) -> None:
        self.aio = SimpleNamespace(models=models)


@pytest.mark.asyncio
async def test_service_sends_only_food_text_and_returns_structured_data() -> None:
    models = FakeModels(
        parsed={
            "foodName": "White rice, cooked",
            "quantity": "1",
            "unit": "cup",
            "calories": "200",
        }
    )
    service = GeminiFoodService(
        client=FakeClient(models),
        model="test-model",
    )

    result = await service.interpret("1 cup rice")

    assert models.call is not None
    assert models.call["contents"] == "1 cup rice"
    assert "meal" not in models.call["contents"].lower()
    assert models.call["model"] == "test-model"
    assert result == GeminiFoodResult(
        foodName="White rice, cooked",
        quantity=1,
        unit="cup",
        calories=200,
    )


@pytest.mark.parametrize("quantity", [0, -1, "many", float("inf")])
def test_invalid_quantity_is_rejected(quantity: Any) -> None:
    with pytest.raises(ValidationError):
        GeminiFoodResult(
            foodName="Rice",
            quantity=quantity,
            unit="cup",
            calories=200,
        )


@pytest.mark.parametrize("calories", [-1, 20.5, "many", float("nan")])
def test_invalid_calories_are_rejected(calories: Any) -> None:
    with pytest.raises(ValidationError):
        GeminiFoodResult(
            foodName="Rice",
            quantity=1,
            unit="cup",
            calories=calories,
        )


@pytest.mark.asyncio
async def test_invalid_model_output_becomes_a_clean_service_error() -> None:
    models = FakeModels(
        parsed={
            "foodName": "Rice",
            "quantity": 0,
            "unit": "cup",
            "calories": -5,
        }
    )
    service = GeminiFoodService(client=FakeClient(models))

    with pytest.raises(GeminiInvalidResponseError):
        await service.interpret("rice")


@pytest.mark.asyncio
async def test_timeout_becomes_a_clean_service_error() -> None:
    models = FakeModels(delay=0.05)
    service = GeminiFoodService(
        client=FakeClient(models),
        timeout_seconds=0.001,
    )

    with pytest.raises(GeminiTimeoutError):
        await service.interpret("rice")


@pytest.mark.asyncio
async def test_sdk_failure_becomes_a_clean_service_error() -> None:
    models = FakeModels(error=RuntimeError("remote failure"))
    service = GeminiFoodService(client=FakeClient(models))

    with pytest.raises(GeminiApiError):
        await service.interpret("rice")


@pytest.mark.asyncio
async def test_missing_api_key_is_reported_without_calling_gemini(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    service = GeminiFoodService(api_key="")

    with pytest.raises(GeminiConfigurationError):
        await service.interpret("rice")
