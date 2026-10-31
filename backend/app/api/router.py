from fastapi import APIRouter
from app.api.v1.endpoints import auth, chat, discovery, health, matches, openai_health

api_router = APIRouter()

# Health endpoints mounted at root /health and /api/v1/health
api_router.include_router(health.router)
api_router.include_router(openai_health.router)

# Discovery and swipe endpoints
api_router.include_router(discovery.router)

# Boundaries
api_router.include_router(auth.router)
api_router.include_router(matches.router)
api_router.include_router(chat.router)
