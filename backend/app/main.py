"""Application entry point for the Caly FastAPI service."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import allowed_frontend_origins
from .routes.foods import router as foods_router

app = FastAPI(
    title="Caly API",
    description="Backend API for Caly's food journal.",
    version="0.1.0",
)

# Flutter web and FastAPI use different localhost ports during development, so
# browsers require explicit CORS permission for those local origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_frontend_origins(),
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type"],
)

app.include_router(foods_router)


@app.get("/health", tags=["health"])
async def health_check() -> dict[str, str]:
    """Return a small response that confirms the API process is available."""

    return {"status": "ok"}
