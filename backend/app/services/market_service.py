from typing import List, Dict, Any
from datetime import datetime
import random

class MarketService:
    def __init__(self):
        # Mock pricing data engine for Phase 1
        self.markets = ["Dambulla", "Pettah"]
        self.crops = ["Tomato", "Chilli", "Beans", "Cabbage", "Paddy"]
        
        # Base realistic prices in LKR per kg
        self.base_prices = {
            "Tomato": 180,
            "Chilli": 450,
            "Beans": 320,
            "Cabbage": 150,
            "Paddy": 110
        }

    def get_daily_prices(self, market: str = "Dambulla") -> List[Dict[str, Any]]:
        """
        Returns mock daily wholesale prices for crops in a specific market.
        Includes a 'trend' indicator (up/down/stable) based on yesterday's mock price.
        """
        prices = []
        today = datetime.now().strftime("%Y-%m-%d")
        
        # Use a deterministic seed based on today's date so prices don't flutter every request
        random.seed(int(datetime.now().strftime("%Y%m%d")))
        
        for crop in self.crops:
            base = self.base_prices[crop]
            
            # Fluctuate base price by +/- 15%
            variation = random.uniform(-0.15, 0.15)
            current_price = int(base * (1 + variation))
            
            # Simulate yesterday's price to determine trend
            yesterday_variation = random.uniform(-0.15, 0.15)
            yesterday_price = int(base * (1 + yesterday_variation))
            
            if current_price > yesterday_price:
                trend = "up"
            elif current_price < yesterday_price:
                trend = "down"
            else:
                trend = "stable"
                
            prices.append({
                "crop": crop,
                "price": current_price,
                "unit": "kg",
                "market": market,
                "date": today,
                "trend": trend,
                "price_diff": abs(current_price - yesterday_price)
            })
            
        return prices
