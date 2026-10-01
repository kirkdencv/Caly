"""Food interpretation routes."""

from functools import lru_cache
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status

from ..schemas import FoodInterpretRequest, FoodInterpretResponse
from ..services.gemini_food_service import (
    GeminiApiError,
    GeminiConfigurationError,
    GeminiFoodService,
    GeminiInvalidResponseError,
    GeminiTimeoutError,
)

router = APIRouter(prefix="/api/v1/foods", tags=["foods"])


@lru_cache
def get_food_interpreter() -> GeminiFoodService:
    """Reuse one Gemini client while keeping the dependency testable."""

    return GeminiFoodService()


@router.post("/interpret", response_model=FoodInterpretResponse)
async def interpret_food(
    request: FoodInterpretRequest,
    interpreter: Annotated[GeminiFoodService, Depends(get_food_interpreter)],
) -> FoodInterpretResponse:
    """Interpret food with Gemini while retaining server-owned request fields."""

    try:
        result = await interpreter.interpret(request.text)
    except GeminiConfigurationError as error:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(error),
        ) from error
    except GeminiTimeoutError as error:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail=str(error),
        ) from error
    except GeminiInvalidResponseError as error:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(error),
        ) from error
    except GeminiApiError as error:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(error),
        ) from error

    return FoodInterpretResponse(
        original_text=request.text,
        food_name=result.food_name,
        quantity=result.quantity,
        unit=result.unit,
        calories=result.calories,
        meal_category=request.meal,
    )
