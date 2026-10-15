from fastapi import APIRouter, HTTPException, status
from app.data.sample_data import SAMPLE_PROFILES
from app.models.profile import Profile, SwipeRequest, SwipeResponse

router = APIRouter(prefix="/api/v1", tags=["discovery"])


@router.get("/discovery", response_model=list[Profile])
async def get_discovery_profiles() -> list[Profile]:
    """Retrieve sample discovery candidates feed."""
    return SAMPLE_PROFILES


@router.get("/profiles/{profile_id}", response_model=Profile)
async def get_profile(profile_id: str) -> Profile:
    """Retrieve a single profile by ID."""
    for profile in SAMPLE_PROFILES:
        if profile.id == profile_id:
            return profile
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"Profile with id '{profile_id}' not found",
    )


@router.post("/swipes", response_model=SwipeResponse)
async def record_swipe(payload: SwipeRequest) -> SwipeResponse:
    """Record a user swipe (like, pass, superlike) on a discovery profile."""
    # Mock behavior: Alex Chen triggers a mutual match for demonstration
    is_match = payload.swipe_type.value in ["like", "superlike"] and payload.profile_id == "usr_01"

    return SwipeResponse(
        success=True,
        profileId=payload.profile_id,
        swipeType=payload.swipe_type,
        matched=is_match,
    )

