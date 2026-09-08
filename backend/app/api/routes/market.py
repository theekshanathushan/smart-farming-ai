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
    Currently returns mock data.
    """
    prices = service.get_daily_prices(market=market)
    return {"status": "success", "data": prices}
