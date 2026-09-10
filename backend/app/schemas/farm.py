from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import uuid

class CropBase(BaseModel):
    name: str
    variety: Optional[str] = None
    plant_date: datetime
    expected_harvest_date: Optional[datetime] = None
    area: Optional[float] = None
    area_unit: Optional[str] = "acres"

class CropCreate(CropBase):
    pass

class Crop(CropBase):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        from_attributes = True

class TaskBase(BaseModel):
    crop_id: str
    title: str
    description: Optional[str] = None
    due_date: datetime
    is_completed: bool = False

class TaskCreate(TaskBase):
    pass

class Task(TaskBase):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        from_attributes = True
