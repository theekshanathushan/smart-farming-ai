import httpx
from typing import Optional, Dict

class WeatherService:
    def __init__(self):
        # Open-Meteo requires no API key for non-commercial use
        self.base_url = "https://api.open-meteo.com/v1/forecast"

    async def get_current_weather(self, lat: float, lon: float) -> Optional[Dict]:
        """
        Fetches current weather for the given coordinates using Open-Meteo.
        Returns a dictionary with temperature, precipitation, etc., or None on failure.
        """
        params = {
            "latitude": lat,
            "longitude": lon,
            "current": "temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,weather_code",
            "timezone": "auto"
        }
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(self.base_url, params=params, timeout=5.0)
                response.raise_for_status()
                data = response.json()
                
                current = data.get("current", {})
                return {
                    "temperature": current.get("temperature_2m"),
                    "humidity": current.get("relative_humidity_2m"),
                    "precipitation": current.get("precipitation"),
                    "wind_speed": current.get("wind_speed_10m"),
                    "description": self._map_weather_code(current.get("weather_code", -1))
                }
            except Exception as e:
                print(f"Error fetching weather: {e}")
                return None

    def _map_weather_code(self, code: int) -> str:
        # Simplified WMO weather interpretation codes
        if code == 0: return "Clear sky"
        elif code in [1, 2, 3]: return "Mainly clear, partly cloudy, or overcast"
        elif code in [45, 48]: return "Fog"
        elif code in [51, 53, 55]: return "Drizzle"
        elif code in [61, 63, 65]: return "Rain"
        elif code in [71, 73, 75]: return "Snow"
        elif code in [95, 96, 99]: return "Thunderstorm"
        return "Unknown"
