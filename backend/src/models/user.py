from pydantic import BaseModel, Field
from typing import List, Optional
from bson import ObjectId


class User(BaseModel):
    id: Optional[str] = Field(default_factory=lambda: str(ObjectId()), alias="_id")
    username: str = Field(...)
    name: Optional[str] = None
    role: str = Field(...)
    email: str = Field(...)
    phone: Optional[str] = None
    address: Optional[str] = None
    requests: Optional[List[str]] = []

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
