from fastapi import APIRouter
from app.config import settings
from app.models.health import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
@router.get("/api/v1/health", response_model=HealthResponse)
async def get_health() -> HealthResponse:
    """Return health check status."""
    return HealthResponse(
        status="ok",
        service=settings.service_name,
    )

