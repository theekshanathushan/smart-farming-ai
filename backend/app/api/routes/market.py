from fastapi import APIRouter, Depends, Query
from typing import List, Dict, Any
from app.services.market_service import MarketService

router = APIRouter()

def get_market_service() -> MarketService:
    return MarketService()

@router.get("/")
async def get_market_prices(
    market: str = Query("Dambulla", description="The market location (e.g. Dambulla, Pettah)"),
    service: MarketService = Depends(get_market_service)
):
    """
    Endpoint to fetch daily wholesale market prices for crops.
    Returns mock data realistic to Sri Lanka.
    """
    mock_data = [
        {"crop": "Tomato", "price": 120, "unit": "1kg", "trend": "up", "market": market},
        {"crop": "Carrot", "price": 250, "unit": "1kg", "trend": "stable", "market": market},
        {"crop": "Green Chili", "price": 450, "unit": "1kg", "trend": "up", "market": market},
        {"crop": "Beans", "price": 180, "unit": "1kg", "trend": "down", "market": market},
        {"crop": "Potato", "price": 200, "unit": "1kg", "trend": "stable", "market": market},
        {"crop": "Big Onion", "price": 300, "unit": "1kg", "trend": "up", "market": market},
        {"crop": "Cabbage", "price": 90, "unit": "1kg", "trend": "down", "market": market},
    ]
    return {"status": "success", "data": mock_data}
