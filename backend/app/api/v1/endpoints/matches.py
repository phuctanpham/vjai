from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/matches", tags=["matches"])


@router.get("")
async def get_matches():
    """Mock matches list endpoint (placeholder boundary)."""
    return {"matches": []}

