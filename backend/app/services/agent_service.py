import os
import json
from openai import AsyncOpenAI
from app.schemas.chat import ChatRequest
from app.services.weather_service import WeatherService

class AgriAgentService:
    def __init__(self):
        # Initialize the AsyncOpenAI client to use Gemini's OpenAI compatible endpoint
        api_key = os.getenv("GEMINI_API_KEY", "dummy_key_for_local_dev")
        self.client = AsyncOpenAI(
            api_key=api_key,
            base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
        )
        self.weather_service = WeatherService()

    async def stream_advice(self, request: ChatRequest):
        system_prompt = (
            "You are AgriAI, an expert agricultural assistant specializing in localized farming advice. "
            "You provide highly accurate, practical, and empathetic advice to farmers. "
            f"You MUST strictly respond in the following language: {request.language}. "
            "CRITICAL: If the language is Sinhala or Tamil, you MUST use the native script (e.g., සිංහල / தமிழ்). "
            "DO NOT use Romanized text (e.g., Singlish/Tanglish). ALWAYS reply in the native alphabet."
        )

        context_parts = []
        if request.crop_type:
            context_parts.append(f"Crop Type: {request.crop_type}")
        
        # Check if we have exact coordinates to fetch real-time weather
        if request.latitude is not None and request.longitude is not None:
            context_parts.append(f"GPS Coordinates: {request.latitude}, {request.longitude}")
            weather_data = await self.weather_service.get_current_weather(request.latitude, request.longitude)
            if weather_data:
                weather_str = (
                    f"Temp: {weather_data['temperature']}°C, "
                    f"Humidity: {weather_data['humidity']}%, "
                    f"Precipitation: {weather_data['precipitation']}mm, "
                    f"Wind: {weather_data['wind_speed']}km/h, "
                    f"Conditions: {weather_data['description']}"
                )
                context_parts.append(f"Current Local Weather: {weather_str}")
            elif request.recent_weather:
                context_parts.append(f"Recent Weather: {request.recent_weather}")
        else:
            if request.gps_zone:
                context_parts.append(f"GPS Zone/Location: {request.gps_zone}")
            if request.recent_weather:
                context_parts.append(f"Recent Weather: {request.recent_weather}")
        
        if context_parts:
            system_prompt += "Here is the localized context for the farmer's field:\n" + "\n".join(context_parts) + "\n"
        else:
            system_prompt += "No specific localized context (crop/weather/location) was provided.\n"

        system_prompt += "Use this context to tailor your advice specifically to their situation."

        # Make the streaming request to OpenAI
        response = await self.client.chat.completions.create(
            model="gemini-3.8-flash",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": request.message}
            ],
            stream=True
        )

        # Yield SSE strings
        async for chunk in response:
            if chunk.choices and chunk.choices[0].delta.content is not None:
                content = chunk.choices[0].delta.content
                # Format as SSE
                data = json.dumps({"delta": content})
                yield f"data: {data}\n\n"
        
        # End of stream marker
        yield "data: [DONE]\n\n"
