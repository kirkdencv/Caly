"""Pydantic request, Gemini-output, and response models for Caly."""

import math
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

MealCategory = Literal["breakfast", "lunch", "dinner"]


class FoodInterpretRequest(BaseModel):
    """JSON body accepted by the food interpretation endpoint."""

    text: str = Field(description="The food note typed by the user")
    meal: MealCategory = Field(description="The meal selected in Flutter")

    @field_validator("text")
    @classmethod
    def text_must_not_be_blank(cls, value: str) -> str:
        """Reject empty or whitespace-only food notes and trim valid input."""

        stripped_value = value.strip()
        if not stripped_value:
            raise ValueError("Food text must not be empty.")
        return stripped_value


class FoodInterpretResponse(BaseModel):
    """Stable structured food result returned to Flutter."""

    model_config = ConfigDict(populate_by_name=True)

    original_text: str = Field(serialization_alias="originalText")
    food_name: str = Field(serialization_alias="foodName")
    quantity: int | float
    unit: str
    calories: int = Field(ge=0)
    meal_category: MealCategory = Field(serialization_alias="mealCategory")


class GeminiFoodResult(BaseModel):
    """The only fields Gemini may generate for one food note."""

    model_config = ConfigDict(populate_by_name=True)

    food_name: str = Field(
        alias="foodName",
        min_length=1,
        description="Normalized, human-readable name of the food",
    )
    quantity: float = Field(
        description="Positive numeric amount represented by the food note",
    )
    unit: str = Field(
        min_length=1,
        description="Short serving unit such as cup, piece, bowl, or serving",
    )
    calories: int = Field(
        description="Estimated calories for the complete stated quantity",
    )

    @model_validator(mode="before")
    @classmethod
    def reject_unexpected_fields(cls, value: object) -> object:
        """Keep validation strict without an unsupported schema keyword."""

        if isinstance(value, dict):
            allowed = {
                "foodName",
                "food_name",
                "quantity",
                "unit",
                "calories",
            }
            unexpected = set(value) - allowed
            if unexpected:
                raise ValueError("Gemini returned unexpected food fields.")
        return value

    @field_validator("food_name", "unit")
    @classmethod
    def text_fields_must_not_be_blank(cls, value: str) -> str:
        """Trim model text and reject strings containing only whitespace."""

        stripped_value = value.strip()
        if not stripped_value:
            raise ValueError("Gemini returned a blank text field.")
        return stripped_value

    @field_validator("quantity", mode="before")
    @classmethod
    def clean_quantity(cls, value: object) -> float:
        """Accept a finite number or numeric string and reject invalid amounts."""

        if isinstance(value, bool):
            raise ValueError("Quantity must be numeric.")
        try:
            quantity = float(value)  # type: ignore[arg-type]
        except (TypeError, ValueError) as error:
            raise ValueError("Quantity must be numeric.") from error
        if not math.isfinite(quantity) or quantity <= 0:
            raise ValueError("Quantity must be a positive finite number.")
        if quantity > 1000:
            raise ValueError("Quantity is outside the supported range.")
        return quantity

    @field_validator("calories", mode="before")
    @classmethod
    def clean_calories(cls, value: object) -> int:
        """Accept whole numeric values and reject negative or fractional values."""

        if isinstance(value, bool):
            raise ValueError("Calories must be a whole number.")
        try:
            calories = float(value)  # type: ignore[arg-type]
        except (TypeError, ValueError) as error:
            raise ValueError("Calories must be numeric.") from error
        if not math.isfinite(calories) or calories < 0:
            raise ValueError("Calories must be a non-negative finite number.")
        if not calories.is_integer():
            raise ValueError("Calories must be a whole number.")
        if calories > 100_000:
            raise ValueError("Calories are outside the supported range.")
        return int(calories)
