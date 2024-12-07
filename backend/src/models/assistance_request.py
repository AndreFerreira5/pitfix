from typing import List, Optional
from pydantic import BaseModel, Field
from bson import ObjectId
from datetime import datetime, timezone


class AssistanceRequest(BaseModel):
    id: Optional[str] = Field(default_factory=lambda: str(ObjectId()), alias="_id")
    title: str = Field(..., description="Title of the assistance request.")
    description: str = Field(..., description="Detailed description of the request.")
    workshop_id: str = Field(..., description="ID of the workshop associated with this request.")
    workers_ids: List[str] = Field(default_factory=list, description="List of worker IDs assigned to this request.")
    is_completed: Optional[bool] = Field(default=False, description="Completion status of the request.")
    creation_date: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), description="Timestamp of when the request was created.")

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


class AssistanceRequestCreate(BaseModel):
    title: str = Field(..., description="Title of the assistance request.")
    description: str = Field(..., description="Detailed description of the request.")
    workshop_id: str = Field(..., description="ID of the workshop associated with this request.")
    workers_ids: List[str] = Field(default_factory=list, description="List of worker IDs assigned to this request.")
    is_completed: Optional[bool] = Field(default=False, description="Completion status of the request.")
    creation_date: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), description="Timestamp of when the request was created.")
