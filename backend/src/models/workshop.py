from typing import List, Optional
from pydantic import BaseModel, Field
from bson import ObjectId
from datetime import datetime, timezone


class Workshop(BaseModel):
    id: Optional[str] = Field(default_factory=lambda: str(ObjectId()), alias="_id")
    name: str = Field(...)
    description: Optional[str] = None
    rating: Optional[float] = None
    image_url: Optional[str] = None
    creation_date: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


class WorkshopCreate(BaseModel):
    name: str
    description: Optional[str] = None
    rating: Optional[float] = None
    image_url: Optional[str] = None
    creation_date: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
