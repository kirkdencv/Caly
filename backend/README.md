# Caly FastAPI backend

This service interprets Flutter food notes with Gemini while keeping the public
JSON contract stable. It does not use Firebase yet.

## What each file does

- `app/main.py` creates the FastAPI application, registers routes, and exposes
  a small health check. It also permits local Flutter web origins through CORS.
- `app/schemas.py` defines and validates request and response JSON with
  Pydantic, including Gemini's structured output.
- `app/routes/foods.py` implements `POST /api/v1/foods/interpret`.
- `app/services/gemini_food_service.py` sends only the food text to Gemini and
  parses its structured response.
- `tests/test_foods.py` tests the API without starting a real network server.
- `tests/test_gemini_food_service.py` tests Gemini request isolation, parsing,
  validation, timeouts, and API failures with a fake client.

## Set up

Run these commands from the repository root:

```powershell
python -m venv backend\.venv
backend\.venv\Scripts\Activate.ps1
python -m pip install -r backend\requirements.txt
```

Copy the example environment file and add your Google AI Studio API key only
to the ignored local copy:

```powershell
Copy-Item backend\.env.example backend\.env
```

```dotenv
GEMINI_API_KEY=your_real_key_here
GEMINI_MODEL=gemini-3.5-flash-lite
GEMINI_TIMEOUT_SECONDS=15
```

`backend/.env` is ignored by Git. Never place a real key in
`backend/.env.example`.

## Run locally

```powershell
python -m uvicorn backend.app.main:app --reload
```

The API is then available at `http://127.0.0.1:8000`.

- Health check: `http://127.0.0.1:8000/health`
- Interactive documentation: `http://127.0.0.1:8000/docs`

## Test independently

```powershell
python -m pytest backend\tests
```

The tests do not call the real Gemini API or consume quota. They cover the
health check, stable response contract, food-text-only model input, whitespace
trimming, blank input, invalid meals, CORS, structured parsing, invalid numeric
values, timeouts, API failures, and missing configuration.

## Stable Flutter contract

Request:

```json
{
  "text": "1 cup rice",
  "meal": "breakfast"
}
```

Response:

```json
{
  "originalText": "1 cup rice",
  "foodName": "White rice, cooked",
  "quantity": 1,
  "unit": "cup",
  "calories": 200,
  "mealCategory": "breakfast"
}
```

`mealCategory` is copied from the request. The backend does not classify the
meal because the user already selected it in Flutter. Gemini generates only
`foodName`, `quantity`, `unit`, and `calories`; Pydantic validates those fields
before FastAPI returns them.

## Failure behavior

- Missing API key or Gemini API failure: HTTP 503
- Gemini timeout: HTTP 504
- Invalid structured Gemini output: HTTP 502
- Invalid Flutter request: HTTP 422

Flutter displays the returned detail on the affected row and lets the user
retry without retyping the food note.

The service first enables Gemini's Google Search grounding so branded and
restaurant foods can use current nutrition information. Search grounding can
have separate usage limits and billing. If Google reports exhausted search
quota, Caly automatically retries once without search and returns the model's
best validated estimate.
