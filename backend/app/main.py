from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import sync, chat, weather, market, farm

app = FastAPI(
    title="AgriAI API",
    description="Backend API for the offline-first agricultural mobile application.",
    version="1.0.0",
)

# Configure CORS
origins = [
    "*", # In production, restrict this to specific domains
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(sync.router, prefix="/api/v1/sync", tags=["sync"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["chat"])
app.include_router(weather.router, prefix="/api/v1/weather", tags=["weather"])
app.include_router(market.router, prefix="/api/v1/market-prices", tags=["market"])
app.include_router(farm.router, prefix="/api/v1/farm", tags=["farm"])

@app.get("/")
async def root():
    return {"message": "Welcome to the AgriAI API"}
