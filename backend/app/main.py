from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import sync, chat

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

@app.get("/")
async def root():
    return {"message": "Welcome to the AgriAI API"}
