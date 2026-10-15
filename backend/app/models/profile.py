from enum import Enum
from pydantic import BaseModel, Field


class SwipeType(str, Enum):
    LIKE = "like"
    PASS = "pass"
    SUPERLIKE = "superlike"


class Profile(BaseModel):
    id: str
    name: str
    age: int
    bio: str
    occupation: str
    distance_km: int = Field(..., alias="distanceKm")
    interests: list[str]
    image_urls: list[str] = Field(default_factory=list, alias="imageUrls")

    class Config:
        populate_by_name = True


class SwipeRequest(BaseModel):
    profile_id: str = Field(..., alias="profileId")
    swipe_type: SwipeType = Field(..., alias="swipeType")

    class Config:
        populate_by_name = True


class SwipeResponse(BaseModel):
    success: bool
    profile_id: str = Field(..., alias="profileId")
    swipe_type: SwipeType = Field(..., alias="swipeType")
    matched: bool = False

    class Config:
        populate_by_name = True

