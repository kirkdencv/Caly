"""Gemini integration for structured food interpretation."""

import asyncio
import os
from pathlib import Path
from typing import Any

from dotenv import load_dotenv
from google import genai
from google.genai import types
from pydantic import ValidationError

from ..schemas import GeminiFoodResult

BACKEND_ENV_FILE = Path(__file__).resolve().parents[2] / ".env"
DEFAULT_MODEL = "gemini-3.5-flash-lite"
DEFAULT_TIMEOUT_SECONDS = 15.0

SYSTEM_INSTRUCTION = """You interpret one food note for a calorie journal.
Return only the requested structured fields. Normalize the food name, extract a
positive numeric quantity and concise unit, and estimate the non-negative whole
calorie total for the complete quantity. Do not add a meal category, original
text, commentary, markdown, or any fields outside the response schema."""


class GeminiFoodServiceError(Exception):
    """Base error that is safe for the API route to translate."""


class GeminiConfigurationError(GeminiFoodServiceError):
    """Raised when no local Gemini API key is configured."""


class GeminiTimeoutError(GeminiFoodServiceError):
    """Raised when Gemini does not return before Caly's deadline."""


class GeminiApiError(GeminiFoodServiceError):
    """Raised when the Gemini SDK or remote API fails."""


class GeminiInvalidResponseError(GeminiFoodServiceError):
    """Raised when Gemini output fails Caly's Pydantic validation."""


class GeminiFoodService:
    """Send food text to Gemini and return a validated structured result."""

    def __init__(
        self,
        *,
        api_key: str | None = None,
        model: str | None = None,
        timeout_seconds: float | None = None,
        client: Any | None = None,
    ) -> None:
        load_dotenv(BACKEND_ENV_FILE)
        self._api_key = (
            os.getenv("GEMINI_API_KEY", "").strip()
            if api_key is None
            else api_key.strip()
        )
        self.model = model or os.getenv("GEMINI_MODEL", DEFAULT_MODEL)
        configured_timeout = os.getenv("GEMINI_TIMEOUT_SECONDS")
        self.timeout_seconds = timeout_seconds or (
            float(configured_timeout)
            if configured_timeout
            else DEFAULT_TIMEOUT_SECONDS
        )
        self._client = client

    def _client_or_raise(self) -> Any:
        if self._client is not None:
            return self._client
        if not self._api_key:
            raise GeminiConfigurationError(
                "Gemini is not configured. Add GEMINI_API_KEY to backend/.env."
            )

        self._client = genai.Client(
            api_key=self._api_key,
            http_options=types.HttpOptions(
                timeout=int(self.timeout_seconds * 1000),
            ),
        )
        return self._client

    async def interpret(self, food_text: str) -> GeminiFoodResult:
        """Interpret only the supplied food text; meal data never reaches Gemini."""

        client = self._client_or_raise()
        try:
            response = await asyncio.wait_for(
                client.aio.models.generate_content(
                    model=self.model,
                    contents=food_text,
                    config=types.GenerateContentConfig(
                        system_instruction=SYSTEM_INSTRUCTION,
                        response_mime_type="application/json",
                        response_schema=GeminiFoodResult,
                        temperature=0.1,
                        automatic_function_calling=types.AutomaticFunctionCallingConfig(
                            disable=True,
                        ),
                    ),
                ),
                timeout=self.timeout_seconds,
            )
        except TimeoutError as error:
            raise GeminiTimeoutError(
                "Gemini took too long to interpret the food. Try again."
            ) from error
        except Exception as error:
            raise GeminiApiError(
                "Gemini could not interpret the food right now. Try again."
            ) from error

        try:
            if isinstance(response.parsed, GeminiFoodResult):
                return response.parsed
            if response.parsed is not None:
                return GeminiFoodResult.model_validate(response.parsed)
            if not response.text:
                raise ValueError("Gemini returned no structured content.")
            return GeminiFoodResult.model_validate_json(response.text)
        except (ValidationError, ValueError, TypeError) as error:
            raise GeminiInvalidResponseError(
                "Gemini returned invalid food information. Try rewording the note."
            ) from error
