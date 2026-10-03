"""Independent tests for the Gemini-backed food interpretation endpoint."""

from fastapi.testclient import TestClient
import pytest

from backend.app.main import app
from backend.app.routes.foods import get_food_interpreter
from backend.app.schemas import GeminiFoodResult
from backend.app.services.gemini_food_service import (
    GeminiApiError,
    GeminiConfigurationError,
    GeminiInvalidResponseError,
    GeminiTimeoutError,
)

client = TestClient(app)


class FakeFoodInterpreter:
    """Predictable replacement that proves the route sends no meal to Gemini."""

    def __init__(self) -> None:
        self.last_food_text: str | None = None
        self.error: Exception | None = None

    async def interpret(self, food_text: str) -> GeminiFoodResult:
        self.last_food_text = food_text
        if self.error is not None:
            raise self.error
        return GeminiFoodResult(
            foodName="White rice, cooked",
            quantity=1,
            unit="cup",
            calories=200,
        )


@pytest.fixture(autouse=True)
def fake_food_interpreter() -> FakeFoodInterpreter:
    fake = FakeFoodInterpreter()
    app.dependency_overrides[get_food_interpreter] = lambda: fake
    yield fake
    app.dependency_overrides.clear()


def test_health_check_confirms_api_is_running() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_interpret_food_keeps_the_flutter_contract() -> None:
    response = client.post(
        "/api/v1/foods/interpret",
        json={"text": "1 cup rice", "meal": "breakfast"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "originalText": "1 cup rice",
        "foodName": "White rice, cooked",
        "quantity": 1,
        "unit": "cup",
        "calories": 200,
        "mealCategory": "breakfast",
    }


def test_interpret_food_trims_text_and_keeps_meal_out_of_gemini(
    fake_food_interpreter: FakeFoodInterpreter,
) -> None:
    response = client.post(
        "/api/v1/foods/interpret",
        json={"text": "  1 cup rice  ", "meal": "lunch"},
    )

    assert response.status_code == 200
    assert response.json()["originalText"] == "1 cup rice"
    assert response.json()["mealCategory"] == "lunch"
    assert fake_food_interpreter.last_food_text == "1 cup rice"


def test_interpret_food_rejects_blank_text() -> None:
    response = client.post(
        "/api/v1/foods/interpret",
        json={"text": "   ", "meal": "breakfast"},
    )

    assert response.status_code == 422
    assert response.json()["detail"][0]["loc"] == ["body", "text"]
    assert "Food text must not be empty" in response.json()["detail"][0]["msg"]


def test_interpret_food_rejects_unreasonably_long_text() -> None:
    response = client.post(
        "/api/v1/foods/interpret",
        json={"text": "a" * 501, "meal": "breakfast"},
    )

    assert response.status_code == 422
    assert response.json()["detail"][0]["loc"] == ["body", "text"]


def test_interpret_food_rejects_unknown_meal() -> None:
    response = client.post(
        "/api/v1/foods/interpret",
        json={"text": "1 cup rice", "meal": "snack"},
    )

    assert response.status_code == 422
    assert response.json()["detail"][0]["loc"] == ["body", "meal"]


def test_local_flutter_origin_passes_cors_preflight() -> None:
    response = client.options(
        "/api/v1/foods/interpret",
        headers={
            "Origin": "http://localhost:8080",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "content-type",
        },
    )

    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == (
        "http://localhost:8080"
    )


@pytest.mark.parametrize(
    ("service_error", "expected_status"),
    [
        (GeminiConfigurationError("Gemini is not configured."), 503),
        (GeminiTimeoutError("Gemini timed out."), 504),
        (GeminiApiError("Gemini is unavailable."), 503),
        (GeminiInvalidResponseError("Gemini returned invalid data."), 502),
    ],
)
def test_gemini_failures_become_clean_http_errors(
    fake_food_interpreter: FakeFoodInterpreter,
    service_error: Exception,
    expected_status: int,
) -> None:
    fake_food_interpreter.error = service_error

    response = client.post(
        "/api/v1/foods/interpret",
        json={"text": "1 cup rice", "meal": "dinner"},
    )

    assert response.status_code == expected_status
    assert response.json()["detail"] == str(service_error)
