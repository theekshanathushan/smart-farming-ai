from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    language: str
    crop_type: Optional[str] = None
    gps_zone: Optional[str] = None
    recent_weather: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class ChatResponseChunk(BaseModel):
    delta: str
