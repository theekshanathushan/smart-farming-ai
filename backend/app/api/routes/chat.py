from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from app.schemas.chat import ChatRequest
from app.services.agent_service import AgriAgentService

router = APIRouter()

# Dependency to inject the service
def get_agent_service() -> AgriAgentService:
    return AgriAgentService()

@router.post("/stream")
async def chat_stream(request: ChatRequest, service: AgriAgentService = Depends(get_agent_service)):
    """
    Endpoint to stream AI advice to the mobile app using Server-Sent Events (SSE).
    """
    return StreamingResponse(
        service.stream_advice(request),
        media_type="text/event-stream"
    )
