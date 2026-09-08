from fastapi import APIRouter, Depends, Query, HTTPException
from typing import Optional, Dict
from app.services.weather_service import WeatherService

router = APIRouter()

def get_weather_service() -> WeatherService:
    return WeatherService()

@router.get("/")
async def get_current_weather(
    lat: float = Query(..., description="Latitude of the location"),
    lon: float = Query(..., description="Longitude of the location"),
    service: WeatherService = Depends(get_weather_service)
):
    """
    Endpoint to get current weather data for the dashboard UI.
    """
    weather_data = await service.get_current_weather(lat, lon)
    if not weather_data:
        raise HTTPException(status_code=502, detail="Failed to fetch weather data from external API")
    return weather_data
