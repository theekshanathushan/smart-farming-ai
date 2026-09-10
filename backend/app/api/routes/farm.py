from fastapi import APIRouter, HTTPException, status
from typing import List
from app.schemas.farm import Crop, CropCreate, Task, TaskCreate
import uuid

router = APIRouter()

# In-memory storage for Phase 1 (Replace with DB later)
MOCK_DB_CROPS = {}
MOCK_DB_TASKS = {}

@router.get("/crops", response_model=List[Crop])
async def get_crops():
    """Retrieve all crops for the user."""
    return list(MOCK_DB_CROPS.values())

@router.post("/crops", response_model=Crop, status_code=status.HTTP_201_CREATED)
async def create_crop(crop_in: CropCreate):
    """Create a new crop."""
    crop = Crop(**crop_in.model_dump())
    MOCK_DB_CROPS[crop.id] = crop
    return crop

@router.get("/tasks", response_model=List[Task])
async def get_tasks(crop_id: str = None):
    """Retrieve tasks, optionally filtered by crop_id."""
    tasks = list(MOCK_DB_TASKS.values())
    if crop_id:
        tasks = [t for t in tasks if t.crop_id == crop_id]
    return tasks

@router.post("/tasks", response_model=Task, status_code=status.HTTP_201_CREATED)
async def create_task(task_in: TaskCreate):
    """Create a new task."""
    task = Task(**task_in.model_dump())
    MOCK_DB_TASKS[task.id] = task
    return task

@router.put("/tasks/{task_id}", response_model=Task)
async def update_task(task_id: str, task_in: TaskCreate):
    """Update an existing task (e.g. mark as completed)."""
    if task_id not in MOCK_DB_TASKS:
        raise HTTPException(status_code=404, detail="Task not found")
    
    updated_task = Task(id=task_id, created_at=MOCK_DB_TASKS[task_id].created_at, **task_in.model_dump())
    MOCK_DB_TASKS[task_id] = updated_task
    return updated_task
