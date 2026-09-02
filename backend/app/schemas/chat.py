from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    language: str
    crop_type: Optional[str] = None
    gps_zone: Optional[str] = None
    recent_weather: Optional[str] = None

class ChatResponseChunk(BaseModel):
    delta: str
