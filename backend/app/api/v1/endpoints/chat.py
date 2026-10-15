from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/chat", tags=["chat"])


@router.get("/conversations")
async def get_conversations():
    """Mock conversations endpoint (placeholder boundary)."""
    return {"conversations": []}

