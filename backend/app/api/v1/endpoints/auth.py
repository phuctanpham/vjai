from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


@router.get("/status")
async def auth_status():
    """Mock auth status endpoint (placeholder boundary)."""
    return {"authenticated": False, "provider": "mock"}

