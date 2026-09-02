import os
import json
from openai import AsyncOpenAI
from app.schemas.chat import ChatRequest

class AgriAgentService:
    def __init__(self):
        # Initialize the AsyncOpenAI client. Expects OPENAI_API_KEY environment variable.
        api_key = os.getenv("OPENAI_API_KEY", "dummy_key_for_local_dev")
        self.client = AsyncOpenAI(api_key=api_key)

    async def stream_advice(self, request: ChatRequest):
        system_prompt = (
            "You are AgriAI, an expert agricultural assistant specializing in localized farming advice. "
            "You provide highly accurate, practical, and empathetic advice to farmers. "
            f"You MUST strictly respond in the following language: {request.language}. "
        )

        context_parts = []
        if request.crop_type:
            context_parts.append(f"Crop Type: {request.crop_type}")
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
            model="gpt-4o",
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
